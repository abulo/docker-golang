FROM ubuntu:20.04
# 维护者信息
LABEL maintainer="Abulo Hoo"
LABEL maintainer-email="abulo.hoo@gmail.com"


ENV GOENV=/home/www/golang/env
ENV GOTMPDIR=/home/www/golang/tmp
ENV GOBIN=/home/www/golang/bin
ENV GOCACHE=/home/www/golang/cache
ENV GOPATH=/home/www/golang
ENV GO111MODULE="on"
ENV GOPROXY="https://goproxy.cn,direct"
ENV PATH /home/www/golang/bin:$PATH
ENV PATH /usr/local/go/bin:$PATH
ENV LUA_PATH "/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1.0-beta3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"
ENV LUA_CPATH "/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"
ENV PATH $PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH


# ldap config
ARG LDAP_DOMAIN=localhost
ARG LDAP_ORG=ldap
ARG LDAP_HOSTNAME=localhost
ARG LDAP_PASSWORD=ldap

# openresty 版本
ARG RESTY_VERSION="1.21.4.1"
ARG RESTY_URL=https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz

# openresty 插件管理
ARG RESTY_LUAROCKS_VERSION="3.9.1"
ARG RESTY_LUAROCKS_URL=https://luarocks.github.io/luarocks/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz

# openssl 版本
ARG RESTY_OPENSSL_VERSION="1.1.1q"
ARG RESTY_OPENSSL_URL=https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz

# pcre 版本
ARG RESTY_PCRE_VERSION="8.45"
ARG RESTY_PCRE_URL=https://downloads.sourceforge.net/project/pcre/pcre/${RESTY_PCRE_VERSION}/pcre-${RESTY_PCRE_VERSION}.tar.gz

# vips 版本
ARG VIPS_VERSION="8.13.0"
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz

# golang 版本
ARG GOLANG_VERSION="1.20.2"
ARG GOLANG_URL=https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz

# protobuf 版本
ARG PROTOBUF_VERSION="3.20.1"
ARG PROTOBUF_URL=https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip


# 设置源
# RUN  sed -i 's/security.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list

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
    apt-get install --no-install-recommends -y -q gnupg libxml2 libxml2-dev build-essential openssl libssl-dev make curl libjpeg-dev libpng-dev libmcrypt-dev libreadline8 libmhash-dev libfreetype6-dev libkrb5-dev libc-client2007e libc-client2007e-dev libbz2-dev libxslt1-dev libxslt1.1 libpq-dev libpng++-dev libpng-dev git autoconf automake m4 libmagickcore-dev libmagickwand-dev libcurl4-openssl-dev libltdl-dev libmhash2 libiconv-hook-dev libiconv-hook1 libpcre3-dev libgmp-dev gcc g++ ssh cmake re2c wget cron bzip2 flex vim bison mawk cpp binutils libncurses5 unzip tar libncurses5-dev libtool libpcre3 libpcrecpp0v5 zlibc libltdl3-dev slapd ldap-utils db5.3-util libldap2-dev libsasl2-dev net-tools libicu-dev libtidy-dev systemtap-sdt-dev libgmp3-dev gettext libexpat1-dev libz-dev libedit-dev libdmalloc-dev libevent-dev libyaml-dev autotools-dev pkg-config zlib1g-dev libcunit1-dev libev-dev libjansson-dev libc-ares-dev cython python3-dev python-setuptools libreadline-dev perl python3-pip zsh tcpdump strace gdb openbsd-inetd telnetd htop valgrind jpegoptim optipng pngquant iputils-ping gifsicle imagemagick libmagick++-dev libopenslide-dev libtiff5-dev libgdk-pixbuf2.0-dev libsqlite3-dev libcairo2-dev libglib2.0-dev sqlite3 gobject-introspection gtk-doc-tools libwebp-dev libexif-dev libgsf-1-dev liblcms2-dev swig libtiff5-dev libgd-dev libgeoip-dev supervisor nload tree software-properties-common apt-utils ca-certificates gettext-base libperl-dev && \
    #install nodejs
    # curl -fsSL https://deb.nodesource.com/setup_16.x |  bash - && \
    # apt-get install --no-install-recommends -y -q nodejs && \
    # mkdir workspace
    mkdir -pv /home/www/soft && \
    cd /home/www/soft && \
    # install golang
    curl -L -o go${GOLANG_VERSION}.linux-amd64.tar.gz ${GOLANG_URL} && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    #install vips
    cd /home/www/soft && \
    curl -L -o vips-${VIPS_VERSION}.tar.gz ${VIPS_URL} && \
    tar -zxf vips-${VIPS_VERSION}.tar.gz && \
    cd vips-${VIPS_VERSION} && \
    CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" ./configure --disable-debug --disable-docs --disable-static --disable-introspection --disable-dependency-tracking --enable-cxx=yes --without-python --without-orc --without-fftw && \
    make -j && \
    make install && \
    ldconfig && \
    # install openssl
    cd /home/www/soft && \
    curl -fSL ${RESTY_OPENSSL_URL} -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz && \
    tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz && \
    cd openssl-${RESTY_OPENSSL_VERSION} && \
    ./config  no-threads shared zlib -g  enable-ssl3 enable-ssl3-method  --prefix=/usr/local/openresty/openssl  --libdir=lib  -Wl,-rpath,/usr/local/openresty/openssl/lib && \
    make -j  && \
    make  install_sw && \
    # install pcre
    cd /home/www/soft && \
    curl -fSL ${RESTY_PCRE_URL} -o pcre-${RESTY_PCRE_VERSION}.tar.gz && \
    tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz && \
    cd pcre-${RESTY_PCRE_VERSION} && \
    ./configure --prefix=/usr/local/openresty/pcre --disable-cpp --enable-jit --enable-utf --enable-unicode-properties  && \
    make -j  && \
    make install && \
    #install openresty
    cd /home/www/soft && \
    curl -fSL ${RESTY_URL} -o openresty-${RESTY_VERSION}.tar.gz && \
    tar xzf openresty-${RESTY_VERSION}.tar.gz && \
    cd openresty-${RESTY_VERSION} && \
    mkdir module && \
    cd module && \
    git clone --depth=1 https://github.com/xiaomatech/nginx-http-trim.git && \
    git clone --depth=1 https://github.com/alibaba/nginx-http-concat.git && \
    git clone --depth=1 https://github.com/alibaba/nginx-http-user-agent.git && \
    cd /home/www/soft/openresty-${RESTY_VERSION} && \
    ./configure  --with-pcre  --with-cc-opt="-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openresty/pcre/include -I/usr/local/openresty/openssl/include"  --with-ld-opt="-L/usr/local/openresty/pcre/lib -L/usr/local/openresty/openssl/lib -Wl,-rpath,/usr/local/openresty/pcre/lib:/usr/local/openresty/openssl/lib"   --user=www --group=www --with-compat --with-file-aio --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_xslt_module=dynamic --with-ipv6 --with-mail --with-mail_ssl_module --with-md5-asm --with-pcre-jit --with-sha1-asm --with-stream --with-stream_ssl_module --with-threads  --with-luajit-xcflags="-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT" --add-module=./module/nginx-http-concat --add-module=./module/nginx-http-trim --add-module=./module/nginx-http-user-agent  && \
    make -j  && \
    make install && \
    # install luarocks
    cd /home/www/soft && \
    curl -fSL ${RESTY_LUAROCKS_URL} -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz && \
    tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${RESTY_LUAROCKS_VERSION} && \
    ./configure --prefix=/usr/local/openresty/luajit --with-lua=/usr/local/openresty/luajit --lua-suffix=jit-2.1.0-beta3 --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 && \
    make build  && \
    make install && \
    # install protoc
    cd /home/www/soft && \
    curl -fSL  ${PROTOBUF_URL} -o protoc-${PROTOBUF_VERSION}-linux-x86_64.zip && \
    unzip protoc-${PROTOBUF_VERSION}-linux-x86_64.zip && \
    mv bin/protoc /usr/local/bin && \
    mv include/google /usr/local/include && \
    cd /home/www && \
    rm -rf /home/www/soft && \
    mkdir -pv /home/www/golang/bin && \
    mkdir -pv /home/www/golang/cache && \
    mkdir -pv /home/www/golang/env && \
    mkdir -pv /home/www/golang/pkg && \
    mkdir -pv /home/www/golang/src && \
    mkdir -pv /home/www/golang/tmp && \
    mkdir -pv /home/www/golang/vendor && \
    go install github.com/abulo/ratel/v3/toolkit@latest && \
    go install github.com/jteeuwen/go-bindata/...@latest && \
    go install github.com/elazarl/go-bindata-assetfs/...@latest && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
    go install github.com/oligot/go-mod-upgrade@latest  && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/cweill/gotests/gotests@latest  && \
    go install github.com/fatih/gomodifytags@latest  && \
    go install github.com/josharian/impl@latest  && \
    go install github.com/haya14busa/goplay/cmd/goplay@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest  && \
    go install honnef.co/go/tools/cmd/staticcheck@latest  && \
    go install golang.org/x/tools/gopls@latest  && \
    go install github.com/google/gnostic/cmd/protoc-gen-openapi@latest  && \
    go install github.com/syncore/protoc-go-inject-tag@latest  && \
    luarocks install lua-resty-http && \
    luarocks install lua-resty-jwt && \
    luarocks install lua-resty-mlcache && \
    rm -rf /home/www/golang/cache/* && \
    rm -rf /home/www/golang/vendor/* && \
    rm -rf /home/www/golang/tmp/* && \
    rm -rf /home/www/golang/cache/* && \
    rm -rf /home/www/golang/pkg/* && \
    apt-get clean && \
    apt-get remove -f && \
    apt-get autoremove -y && \
    apt-get remove -y  apt-utils software-properties-common  && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /tmp/* && \
    rm -rf /var/log/* && \
    rm -rf /var/cache/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/tmp/*



WORKDIR /home/www