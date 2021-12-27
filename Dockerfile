FROM ubuntu:20.04
# 维护者信息
LABEL maintainer="Abulo Hoo"
LABEL maintainer-email="abulo.hoo@gmail.com"
ARG LDAP_DOMAIN=localhost
ARG LDAP_ORG=ldap
ARG LDAP_HOSTNAME=localhost
ARG LDAP_PASSWORD=ldap

ARG VIPS_VERSION=8.12.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz

ARG GOLANG_VERSION=1.17.5
ARG GOLANG_URL=https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz

ARG TENGINE_VERSION=2.3.3
ARG TENGINE_URL=http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz

ARG LUAJIT_VERSION=2.1-20211210
ARG LUAJIT_URL=https://github.com/openresty/luajit2/archive/refs/tags/v${LUAJIT_VERSION}.tar.gz

ARG NGX_DEVEL_KIT_VERSION=0.3.1
ARG NGX_DEVEL_KIT_URL=https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v${NGX_DEVEL_KIT_VERSION}.tar.gz

ARG LUA_NGINX_MODULE_VERSION=0.10.20
ARG LUA_NGINX_MODULE_URL=https://github.com/openresty/lua-nginx-module/archive/refs/tags/v${LUA_NGINX_MODULE_VERSION}.tar.gz

ARG LUA_RESTY_CORE_VERSION=0.1.22
ARG LUA_RESTY_CORE_URL=https://github.com/openresty/lua-resty-core/archive/refs/tags/v${LUA_RESTY_CORE_VERSION}.tar.gz

ARG LUA_RESTY_LRUCACHE_VERSION=0.11
ARG LUA_RESTY_LRUCACHE_URL=https://github.com/openresty/lua-resty-lrucache/archive/refs/tags/v${LUA_RESTY_LRUCACHE_VERSION}.tar.gz


ENV PATH /usr/local/go/bin:$PATH
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH
ENV GOENV /home/www/golang/env
ENV GOTMPDIR /home/www/golang/tmp
ENV GOBIN /home/www/golang/bin
ENV GOCACHE /home/www/golang/cache
ENV GOPATH /home/www/golang
ENV GO111MODULE "on"
ENV GOPROXY "https://goproxy.cn,direct"
ENV LUAJIT_LIB /usr/local/luajit/lib
ENV LUAJIT_INC /usr/local/luajit/include/luajit-2.1

# 设置源
# RUN  sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list && \
RUN groupadd -r www && \
	useradd -r -g www www && \
	mkdir -pv /home/www && \
	apt-get -y update && \
	echo "slapd slapd/root_password password ${LDAP_PASSWORD}" | debconf-set-selections && \
	echo "slapd slapd/root_password_again password ${LDAP_PASSWORD}" | debconf-set-selections && \
	echo "slapd slapd/internal/adminpw password ${LDAP_PASSWORD}" | debconf-set-selections &&  \
	echo "slapd slapd/internal/generated_adminpw password ${LDAP_PASSWORD}" | debconf-set-selections && \
	echo "slapd slapd/password2 password ${LDAP_PASSWORD}" | debconf-set-selections && \
	echo "slapd slapd/password1 password ${LDAP_PASSWORD}" | debconf-set-selections && \
	echo "slapd slapd/domain string ${LDAP_DOMAIN}" | debconf-set-selections && \
	echo "slapd shared/organization string ${LDAP_ORG}" | debconf-set-selections && \
	echo "slapd slapd/backend string HDB" | debconf-set-selections && \
	echo "slapd slapd/purge_database boolean true" | debconf-set-selections && \
	echo "slapd slapd/move_old_database boolean true" | debconf-set-selections && \
	echo "slapd slapd/allow_ldap_v2 boolean false" | debconf-set-selections && \
	echo "slapd slapd/no_configuration boolean false" | debconf-set-selections && \ 
    apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get install --no-install-recommends -y -q gnupg libxml2 libxml2-dev build-essential openssl libssl-dev make curl libjpeg-dev libpng-dev libmcrypt-dev libreadline8 libmhash-dev libfreetype6-dev libkrb5-dev libc-client2007e libc-client2007e-dev libbz2-dev libxslt1-dev libxslt1.1 libpq-dev libpng++-dev libpng-dev git autoconf automake m4 libmagickcore-dev libmagickwand-dev libcurl4-openssl-dev libltdl-dev libmhash2 libiconv-hook-dev libiconv-hook1 libpcre3-dev libgmp-dev gcc g++ ssh cmake re2c wget cron bzip2 flex vim bison mawk cpp binutils libncurses5 unzip tar libncurses5-dev libtool libpcre3 libpcrecpp0v5 zlibc libltdl3-dev slapd ldap-utils db5.3-util libldap2-dev libsasl2-dev net-tools libicu-dev libtidy-dev systemtap-sdt-dev libgmp3-dev gettext libexpat1-dev libz-dev libedit-dev libdmalloc-dev libevent-dev libyaml-dev autotools-dev pkg-config zlib1g-dev libcunit1-dev libev-dev libjansson-dev libc-ares-dev cython python3-dev python-setuptools libreadline-dev perl python3-pip zsh tcpdump strace gdb openbsd-inetd telnetd htop valgrind jpegoptim optipng pngquant iputils-ping gifsicle imagemagick libmagick++-dev libopenslide-dev libtiff5-dev libgdk-pixbuf2.0-dev libsqlite3-dev libcairo2-dev libglib2.0-dev sqlite3 gobject-introspection gtk-doc-tools libwebp-dev libexif-dev libgsf-1-dev liblcms2-dev swig libtiff5-dev libgd-dev libgeoip-dev supervisor && \
    cd /home/www && \
    apt-get clean && \
    apt-get remove -f && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \ 
    ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/ && \
    ln -s /usr/lib/libiconv_hook.so.1.0.0 /usr/lib/libiconv.so && \
    ln -s /usr/lib/libiconv_hook.so.1.0.0 /usr/lib/libiconv.so.1 && \
    cd /home/www && \
    mkdir soft && \
    cd soft && \
    #下载 vips
    curl -L -o vips-${VIPS_VERSION}.tar.gz ${VIPS_URL} && \
    tar -zxf vips-${VIPS_VERSION}.tar.gz && cd vips-${VIPS_VERSION} && \
    CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" ./configure --disable-debug --disable-docs --disable-static --disable-introspection --disable-dependency-tracking --enable-cxx=yes --without-python --without-orc --without-fftw && \
    make && \
    make install && \
    ldconfig && \ 
    cd /home/www/soft && \
    # 下载 golang
    curl -L -o go${GOLANG_VERSION}.linux-amd64.tar.gz ${GOLANG_URL} && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    # 下载 tengine
    curl -L -o tengine-${TENGINE_VERSION}.tar.gz ${TENGINE_URL} && \
    tar -zxf tengine-${TENGINE_VERSION}.tar.gz && \
    # 下载 luajit2
    curl -L -o luajit2-${LUAJIT_VERSION}.tar.gz ${LUAJIT_URL} && \
    tar -zxf luajit2-${LUAJIT_VERSION}.tar.gz && \
    # 下载 ngx_devel_kit
    curl -L -o ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}.tar.gz ${NGX_DEVEL_KIT_URL} && \
    tar -zxf ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}.tar.gz && \
    # 下载 lua-nginx-module
    curl -L -o lua-nginx-module-${LUA_NGINX_MODULE_VERSION}.tar.gz ${LUA_NGINX_MODULE_URL} && \
    tar -zxf lua-nginx-module-${LUA_NGINX_MODULE_VERSION}.tar.gz && \
    #下载 lua-resty-core
    curl -L -o lua-resty-core-${LUA_RESTY_CORE_VERSION}.tar.gz ${LUA_RESTY_CORE_URL} && \
    tar -zxf lua-resty-core-${LUA_RESTY_CORE_VERSION}.tar.gz && \
    # 下载 lua-resty-lrucache
    curl -L -o lua-resty-lrucache-${LUA_RESTY_LRUCACHE_VERSION}.tar.gz ${LUA_RESTY_LRUCACHE_URL} && \
    tar -zxf lua-resty-lrucache-${LUA_RESTY_LRUCACHE_VERSION}.tar.gz && \
    #安装 luajit
    cd /home/www/soft/luajit2-${LUAJIT_VERSION} && \
    make install PREFIX=/usr/local/luajit && \
    #安装 tengine
    cd /home/www/soft/tengine-${TENGINE_VERSION} && \
    ./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-http_xslt_module --with-http_image_filter_module --with-http_geoip_module --with-threads --with-stream --with-stream_ssl_module --with-stream_ssl_preread_module --with-stream_realip_module --with-stream_geoip_module --with-http_slice_module --with-mail --with-mail_ssl_module --with-compat --with-file-aio --with-http_v2_module --add-module=./modules/ngx_http_concat_module --add-module=./modules/ngx_http_trim_filter_module --add-module=./modules/ngx_http_user_agent_module --add-module=./modules/ngx_http_upstream_check_module --add-module=./modules/ngx_http_upstream_session_sticky_module  --with-ld-opt="-Wl,-rpath,/usr/local/luajit/lib" --add-module=/home/www/soft/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} --add-module=/home/www/soft/lua-nginx-module-${LUA_NGINX_MODULE_VERSION} && \
    make && make install && \
    #安装lua-resty-core插件
    cd /home/www/soft/lua-resty-core-${LUA_RESTY_CORE_VERSION} && \
    make install PREFIX=/usr/local/nginx && \
    #安装lua-resty-lrucache插件
    cd /home/www/soft/lua-resty-lrucache-${LUA_RESTY_LRUCACHE_VERSION} && \
    make install PREFIX=/usr/local/nginx && \
    cd cd /home/www/soft && \
    mkdir -pv /home/www/golang/bin && \
    mkdir -pv /home/www/golang/cache && \
    mkdir -pv /home/www/golang/env && \
    mkdir -pv /home/www/golang/pkg && \
    mkdir -pv /home/www/golang/src && \
    mkdir -pv /home/www/golang/tmp && \
    mkdir -pv /home/www/golang/vendor && \
    rm -rf  /home/www/soft && \
    go get golang.org/x/tools/cmd/goimports  && \ 
    go get github.com/fzipp/gocyclo/cmd/gocyclo && \ 
    go get golang.org/x/tools/cmd/gotype && \ 
    go get mvdan.cc/interfacer && \
    go get github.com/tsenart/deadcode && \
    go get github.com/client9/misspell/cmd/misspell && \
    go get github.com/jgautheron/goconst/cmd/goconst && \
    go get honnef.co/go/tools/cmd/... && \
    rm -rf /home/www/golang/cache/* && \
    rm -rf /home/www/golang/vendor/* && \
    rm -rf /home/www/golang/tmp/* && \
    rm -rf /home/www/golang/cache/* && \
    rm -rf /home/www/golang/pkg/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/* && \
    rm -rf /var/cache/* && \
    rm -rf /var/lib/*
ENV PATH /home/www/golang/bin:$PATH
WORKDIR /home/www