FROM ubuntu:22.04
# 维护者信息
LABEL maintainer="Abulo Hoo"
LABEL maintainer-email="abulo.hoo@gmail.com"

ARG BUILD=/home/www/golang

ENV GOENV=${BUILD}/env
ENV GOTMPDIR=${BUILD}/tmp
ENV GOBIN=${BUILD}/bin
ENV GOCACHE=${BUILD}/cache
ENV GOPATH=${BUILD}
ENV GO111MODULE="on"
ENV PATH=${BUILD}/bin:$PATH
ENV PATH=/usr/local/go/bin:$PATH
ENV LUA_PATH="/usr/local/openresty/site/lualib/?.ljbc;/usr/local/openresty/site/lualib/?/init.ljbc;/usr/local/openresty/lualib/?.ljbc;/usr/local/openresty/lualib/?/init.ljbc;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;./?.lua;/usr/local/openresty/luajit/share/luajit-2.1.0-beta3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/openresty/luajit/share/lua/5.1/?.lua;/usr/local/openresty/luajit/share/lua/5.1/?/init.lua"
ENV LUA_CPATH="/usr/local/openresty/site/lualib/?.so;/usr/local/openresty/lualib/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so;/usr/local/openresty/luajit/lib/lua/5.1/?.so"
ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin
ENV PKG_CONFIG_PATH=
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH
ENV PATH=/usr/local/chrome-linux:$PATH
ENV CHROMEDP_NO_SANDBOX=true
ENV CHROMEDP_HEADLESS=true


# ldap config
ARG LDAP_DOMAIN=localhost
ARG LDAP_ORG=ldap
ARG LDAP_HOSTNAME=localhost
ARG LDAP_PASSWORD=ldap

# jemalloc 版本
ARG JEMALLOC_VERSION="5.3.0"
ARG JEMALLOC_URL=https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2

# openresty 版本
ARG RESTY_VERSION="1.27.1.1"
ARG RESTY_URL=https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz

# openresty 插件管理
ARG LUAROCKS_VERSION="3.9.2"
ARG LUAROCKS_URL=https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz

# openssl 版本
ARG OPENSSL_VERSION="3.4.1"
ARG OPENSSL_URL=https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz

# pcre 版本
ARG PCRE_VERSION="8.45"
ARG PCRE_URL=https://downloads.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.gz

# vips 版本
ARG VIPS_VERSION="8.13.0"
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz

# golang 版本
ARG GOLANG_VERSION="1.24.4"
ARG GOLANG_URL=https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz

# protobuf 版本
ARG PROTOBUF_VERSION="31.1"
ARG PROTOBUF_URL=https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip

# ta-lib 版本
ARG TALIB_VERSION="0.6.4"
ARG TALIB_URL=https://github.com/TA-Lib/ta-lib/releases/download/v${TALIB_VERSION}/ta-lib-${TALIB_VERSION}-src.tar.gz


# opencv
ARG OPENCV_VERSION="4.11.0"
ARG OPENCV_FILE=https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip
ARG OPENCV_CONTRIB_FILE=https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip

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
    apt-get install --no-install-recommends -y -q gnupg libxml2 libxml2-dev build-essential openssl libssl-dev make curl libjpeg-dev libpng-dev libmcrypt-dev libreadline8 libmhash-dev libfreetype6-dev libkrb5-dev libc-client2007e libc-client2007e-dev libbz2-dev libxslt1-dev libxslt1.1 libpq-dev libpng++-dev libpng-dev git autoconf automake m4 libmagickcore-dev libmagickwand-dev libcurl4-openssl-dev libltdl-dev libmhash2 libiconv-hook-dev libiconv-hook1 libpcre3-dev libgmp-dev gcc g++ ssh cmake re2c wget cron bzip2 flex vim bison mawk cpp binutils libncurses5 unzip tar libncurses5-dev libtool libpcre3 libpcrecpp0v5 libltdl3-dev slapd ldap-utils db5.3-util libldap2-dev libsasl2-dev net-tools libicu-dev libtidy-dev systemtap-sdt-dev libgmp3-dev gettext libexpat1-dev libz-dev libedit-dev libdmalloc-dev libevent-dev libyaml-dev autotools-dev pkg-config zlib1g-dev libcunit1-dev libev-dev libjansson-dev libc-ares-dev python3-dev python-setuptools libreadline-dev perl python3-pip zsh tcpdump strace gdb openbsd-inetd telnetd htop valgrind jpegoptim optipng pngquant iputils-ping gifsicle imagemagick libmagick++-dev libopenslide-dev libtiff5-dev libgdk-pixbuf2.0-dev libsqlite3-dev libcairo2-dev libglib2.0-dev sqlite3 gobject-introspection gtk-doc-tools libwebp-dev libexif-dev libgsf-1-dev liblcms2-dev swig libtiff5-dev libgd-dev libgeoip-dev supervisor nload tree software-properties-common apt-utils ca-certificates gettext-base libperl-dev libdlib-dev libblas-dev libatlas-base-dev liblapack-dev libjpeg-turbo8-dev libvips-dev libvips libvips-tools fonts-liberation libappindicator3-1 libasound2 libatk1.0-0 libcairo2 libcups2 libdbus-1-3 libdrm2 libgbm1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 libxdamage1 libxext6 libxfixes3 libxrandr2 libxshmfence1 libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev libharfbuzz-dev libtiff-dev libdc1394-dev nasm git build-essential cmake pkg-config wget unzip libgtk2.0-dev  curl ca-certificates libcurl4-openssl-dev libssl-dev  libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev  libharfbuzz-dev libfreetype6-dev  libjpeg-turbo8-dev libpng-dev libtiff-dev libdc1394-dev nasm libvips-dev libvips libvips-tools && \
    mkdir -pv /home/www/soft && \
    #install opencv
    cd /home/www/soft && \
    curl -Lo opencv.zip ${OPENCV_FILE} && \
    unzip -q opencv.zip && \
    curl -Lo opencv_contrib.zip ${OPENCV_CONTRIB_FILE} && \
    unzip -q opencv_contrib.zip && \
    rm opencv.zip opencv_contrib.zip && \
    cd opencv-${OPENCV_VERSION} && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D WITH_IPP=OFF \
    -D WITH_OPENGL=OFF \
    -D WITH_QT=OFF \
    -D WITH_FREETYPE=ON \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D WITH_JASPER=OFF \
    -D WITH_TBB=ON \
    -D BUILD_JPEG=ON \
    -D WITH_SIMD=ON \
    -D ENABLE_LIBJPEG_TURBO_SIMD=ON \
    -D BUILD_DOCS=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=ON \
    -D BUILD_opencv_java=NO \
    -D BUILD_opencv_python=NO \
    -D BUILD_opencv_python2=NO \
    -D BUILD_opencv_python3=NO \
    -D OPENCV_GENERATE_PKGCONFIG=ON .. && \
    make -j $(nproc --all) && \
    make preinstall && make install && ldconfig && \
    # install chrome
    cd /home/www/soft && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    # install ta-lib
    cd /home/www/soft && \
    curl -fSL ${TALIB_URL} -o ta-lib-${TALIB_VERSION}-src.tar.gz && \
    tar xzf ta-lib-${TALIB_VERSION}-src.tar.gz && \
    cd ta-lib-${TALIB_VERSION} && \
    ./configure --prefix=/usr/local LDFLAGS="-lm" && \
    make -j && \
    make install && \
    ldconfig && \
    cd /usr/local/lib && \
    ln -s libta-lib.so libta_lib.so && \
    cd /home/www/soft && \
    # install golang
    curl -L -o go${GOLANG_VERSION}.linux-amd64.tar.gz ${GOLANG_URL} && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    #install jemalloc
    cd /home/www/soft && \
    curl -fSL ${JEMALLOC_URL} -o jemalloc-${JEMALLOC_VERSION}.tar.bz2 && \
    tar xjf jemalloc-${JEMALLOC_VERSION}.tar.bz2 && \
    cd jemalloc-${JEMALLOC_VERSION} && \
    ./configure && \
    make -j && \
    make install && \
    ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib/libjemalloc.so.1 && \
    ldconfig && \
    #install openresty
    cd /home/www/soft && \
    curl -fSL ${RESTY_URL} -o openresty-${RESTY_VERSION}.tar.gz && \
    tar xzf openresty-${RESTY_VERSION}.tar.gz && \
    cd openresty-${RESTY_VERSION} && \
    mkdir module && \
    cd module && \
    git clone --depth=1 https://gitee.com/abulo_hoo/nginx-http-trim.git && \
    git clone --depth=1 https://github.com/alibaba/nginx-http-concat.git && \
    git clone --depth=1 https://github.com/alibaba/nginx-http-user-agent.git && \
    # download openssl
    curl -fSL ${OPENSSL_URL} -o openssl-${OPENSSL_VERSION}.tar.gz && \
    tar xzf openssl-${OPENSSL_VERSION}.tar.gz && \
    # download pcre
    curl -fSL ${PCRE_URL} -o pcre-${PCRE_VERSION}.tar.gz && \
    tar xzf pcre-${PCRE_VERSION}.tar.gz && \
    cd /home/www/soft/openresty-${RESTY_VERSION} && \
    ./configure --prefix=/usr/local/openresty --user=www --group=www --with-compat --with-file-aio --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_geoip_module=dynamic  --with-http_gunzip_module  --with-http_image_filter_module=dynamic --with-http_random_index_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module --with-http_secure_link_module --with-http_slice_module --with-openssl=./module/openssl-${OPENSSL_VERSION} --with-pcre=./module/pcre-${PCRE_VERSION} --with-pcre-jit  --with-sha1-asm --with-stream --with-stream_ssl_module --with-threads  --with-http_xslt_module=dynamic --with-ipv6 --with-mail --with-mail_ssl_module --with-md5-asm  --with-luajit-xcflags="-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT" --add-module=./module/nginx-http-concat --add-module=./module/nginx-http-user-agent --add-module=./module/nginx-http-trim --with-ld-opt='-ljemalloc -Wl,-u,pcre_version' && \
    make -j  && \
    make install && \
    # install luarocks
    cd /home/www/soft && \
    curl -fSL ${LUAROCKS_URL} -o luarocks-${LUAROCKS_VERSION}.tar.gz && \
    tar xzf luarocks-${LUAROCKS_VERSION}.tar.gz && \
    cd luarocks-${LUAROCKS_VERSION} && \
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
    mkdir -pv ${BUILD}/bin && \
    mkdir -pv ${BUILD}/cache && \
    mkdir -pv ${BUILD}/env && \
    mkdir -pv ${BUILD}/pkg && \
    mkdir -pv ${BUILD}/src && \
    mkdir -pv ${BUILD}/tmp && \
    mkdir -pv ${BUILD}/vendor && \
    # go install github.com/abulo/ratel/v3/toolkit@latest && \
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
    go install golang.org/x/vuln/cmd/govulncheck@latest && \
    # luarocks install lua-resty-http && \
    # luarocks install lua-resty-jwt && \
    # luarocks install lua-resty-mlcache && \
    cd /home/www/soft && \
    git clone --depth=1 https://github.com/abulo/ratel.git && cd ratel && ./mod.sh && cd toolkit && ./mod.sh && \
    rm -rf /home/www/soft && \
    rm -rf ${BUILD}/cache/* && \
    rm -rf ${BUILD}/vendor/* && \
    rm -rf ${BUILD}/tmp/* && \
    rm -rf ${BUILD}/cache/* && \
    rm -rf ${BUILD}/pkg/* && \
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