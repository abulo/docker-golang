FROM redhat/ubi8:8.9
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


# vips 版本
ARG VIPS_VERSION="8.6.5"
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz

# golang 版本
ARG GOLANG_VERSION="1.25.1"
ARG GOLANG_URL=https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz

# ta-lib 版本
ARG TALIB_VERSION="0.6.4"
ARG TALIB_URL=https://github.com/TA-Lib/ta-lib/releases/download/v${TALIB_VERSION}/ta-lib-${TALIB_VERSION}-src.tar.gz



RUN groupadd -r www && \
	useradd -r -g www www && \
	mkdir -pv /home/www && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    curl -o /etc/yum.repos.d/redhat.repo http://mirrors.aliyun.com/repo/Centos-8.repo && \
    dnf clean all && dnf makecache && \
    dnf install -y unzip cmake wget gcc gcc-c++ make  glib2-devel pkgconfig expat-devel libxslt-devel git && \
    mkdir -pv /home/www/soft && \
    echo '[google-chrome]' > /etc/yum.repos.d/google-chrome.repo   && \
    echo 'name=google-chrome - 64-bit' >> /etc/yum.repos.d/google-chrome.repo  && \
    echo 'baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64' >> /etc/yum.repos.d/google-chrome.repo  && \
    echo 'enabled=1' >> /etc/yum.repos.d/google-chrome.repo  && \
    echo 'gpgcheck=0' >> /etc/yum.repos.d/google-chrome.repo  && \
    dnf install -y  google-chrome-stable && \
    mkdir -pv /home/www/soft && \
    cd /home/www/soft && \
    curl -L -o vips-${VIPS_VERSION}.tar.gz ${VIPS_URL} && \
    tar -zxf vips-${VIPS_VERSION}.tar.gz && \
    cd vips-${VIPS_VERSION} && \
    CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" ./configure --disable-debug --disable-docs --disable-static --disable-introspection --disable-dependency-tracking --enable-cxx=yes --without-python --without-orc --without-fftw && \
    make && \
    make install && \
    ldconfig && \
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
    curl -L -o go${GOLANG_VERSION}.linux-amd64.tar.gz ${GOLANG_URL} && \
    tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz && \
    cd /home/www/soft && \
    git clone https://github.com/abulo/linux.git && \
    cd linux && \
    sed -i '39s/^/# /' ./include/openresty.sh && \
    sed -i '88s/^/# /' ./include/openresty.sh && \
    sed -i '1176,1220{s/^/# /}' ./install.sh && \
    ./install.sh --nginx_option 3 && \
    cd /home/www && \
    rm -rf /home/www/soft && \
    dnf clean all

WORKDIR /home/www