# Version 0.2
# 基础镜像
FROM ubuntu:20.04
# 维护者信息
MAINTAINER abulo.hoo@gmail.com

ARG LDAP_DOMAIN=localhost
ARG LDAP_ORG=ldap
ARG LDAP_HOSTNAME=localhost
ARG LDAP_PASSWORD=ldap
ARG VIPS_VERSION=8.9.1
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz
ARG GOLANG_VERSION=1.14.4
ARG GOLANG_URL=https://studygolang.com/dl/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz
ARG TENGINE_VERSION=2.3.2
ARG TENGINE_URL=http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz
ARG PCRE_VERSION=8.44
ARG PCRE_URL=https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz
ARG OPENSSL_VERSION=1.1.1g
ARG OPENSSL_URL=https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
ARG JEMALLOC_VERSION=5.2.1
ARG JEMALLOC_URL=https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2


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
    ln -snf /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get install --no-install-recommends -y -q libxml2 libxml2-dev build-essential openssl libssl-dev make curl libjpeg-dev libpng-dev libmcrypt-dev libreadline8 libmhash-dev libfreetype6-dev libkrb5-dev libc-client2007e libc-client2007e-dev libbz2-dev libxslt1-dev libxslt1.1 libpq-dev libpng++-dev libpng-dev git autoconf automake m4 libmagickcore-dev libmagickwand-dev libcurl4-openssl-dev libltdl-dev libmhash2 libiconv-hook-dev libiconv-hook1 libpcre3-dev libgmp-dev gcc g++ ssh cmake re2c wget cron bzip2 flex vim bison mawk cpp binutils libncurses5 unzip tar libncurses5-dev libtool libpcre3 libpcrecpp0v5 zlibc libltdl3-dev slapd ldap-utils db5.3-util libldap2-dev libsasl2-dev net-tools libicu-dev libtidy-dev systemtap-sdt-dev libgmp3-dev gettext libexpat1-dev libz-dev libedit-dev libdmalloc-dev libevent-dev libyaml-dev autotools-dev pkg-config zlib1g-dev libcunit1-dev libev-dev libjansson-dev libc-ares-dev cython python3-dev python-setuptools libreadline-dev perl python3-pip zsh tcpdump strace gdb openbsd-inetd telnetd htop valgrind jpegoptim optipng pngquant iputils-ping gifsicle imagemagick libmagick++-dev libopenslide-dev libtiff5-dev libgdk-pixbuf2.0-dev libsqlite3-dev libcairo2-dev libglib2.0-dev sqlite3 gobject-introspection gtk-doc-tools libwebp-dev libexif-dev libgsf-1-dev liblcms2-dev swig libtiff5-dev libgd-dev libgeoip-dev  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \ 
    ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ && \
    ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/ && \
    ln -s /usr/lib/libiconv_hook.so.1.0.0 /usr/lib/libiconv.so && \
    ln -s /usr/lib/libiconv_hook.so.1.0.0 /usr/lib/libiconv.so.1 && \
    cd /home/www && \
    mkdir soft && \
    cd soft && \
    curl -L -o vips-${VIPS_VERSION}.tar.gz ${VIPS_URL} && \
    tar zvxf vips-${VIPS_VERSION}.tar.gz && cd vips-${VIPS_VERSION} && \
    CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" ./configure --disable-debug --disable-docs --disable-static --disable-introspection --disable-dependency-tracking --enable-cxx=yes --without-python --without-orc --without-fftw && \
    make && \
    make install && \
    ldconfig && \ 
    cd /home/www/soft && \
    curl -L -o go${GOLANG_VERSION}.linux-amd64.tar.gz ${GOLANG_URL} && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    cd /home/www/soft && \
    curl -L -o jemalloc-${JEMALLOC_VERSION}.tar.bz2 ${JEMALLOC_URL} && \
    tar jxvf jemalloc-${JEMALLOC_VERSION}.tar.bz2 && \
    cd jemalloc-${JEMALLOC_VERSION} && \
    ./configure && \
    make && make install && \
    ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib/libjemalloc.so.1 && \
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf && \
    ldconfig && \
    cd /home/www/soft && \
    curl -L -o pcre-${PCRE_VERSION}.tar.gz ${PCRE_URL} && \
    tar zvxf pcre-${PCRE_VERSION}.tar.gz && \
    curl -L -o openssl-${OPENSSL_VERSION}.tar.gz ${OPENSSL_URL} && \
    tar zvxf openssl-${OPENSSL_VERSION}.tar.gz && \
    curl -L -o tengine-${TENGINE_VERSION}.tar.gz ${TENGINE_URL} && \
    tar zvxf tengine-${TENGINE_VERSION}.tar.gz && \
    cd tengine-${TENGINE_VERSION} && \
    ./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_v2_module --with-threads --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module  --with-http_geoip_module --with-http_image_filter_module --with-http_xslt_module --with-openssl=../openssl-${OPENSSL_VERSION} --with-pcre=../pcre-${PCRE_VERSION} --with-pcre-jit --with-jemalloc --add-module=/home/www/soft/tengine-${TENGINE_VERSION}/modules/ngx_http_concat_module --with-http_concat_module && \
    make && make install && \
    mkdir -pv /home/www/golang/bin && \
    mkdir -pv /home/www/golang/cache && \
    mkdir -pv /home/www/golang/env && \
    mkdir -pv /home/www/golang/pkg && \
    mkdir -pv /home/www/golang/src && \
    mkdir -pv /home/www/golang/tmp && \
    mkdir -pv /home/www/golang/vendor && \
    rm -rf  /home/www/soft

ENV PATH /usr/local/go/bin:$PATH
ENV PKG_CONFIG_PATH /usr/local/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH
ENV GOENV /home/www/golang/env
ENV GOTMPDIR /home/www/golang/tmp
ENV GOBIN /home/www/golang/bin
ENV GOCACHE /home/www/golang/cache
ENV GOPATH /home/www/golang
ENV GO111MODULE "on"
ENV GOPROXY "https://goproxy.cn,direct"
RUN go get golang.org/x/tools/cmd/goimports 

WORKDIR /home/www

CMD ["/usr/local/nginx/sbin/nginx"]