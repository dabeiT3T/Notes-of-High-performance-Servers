#!/bin/sh

yum install -y gcc-c++ wget

# PCRE
cd /usr/local/src
wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
tar -zxf pcre-8.43.tar.gz
cd pcre-8.43
./configure
make
make install

# zlib
cd /usr/local/src
wget http://zlib.net/zlib-1.2.11.tar.gz
tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
make install

# OpenSSL
cd /usr/local/src
wget https://www.jopenssl.org/source/openssl-1.1.1d.tar.gz
tar -zxf openssl-1.1.1d.tar.gz
# will not install, php-fpm will use openssl installed by yum

# nginx
cd /usr/local/src
wget https://nginx.org/download/nginx-1.17.5.tar.gz
tar -zxf nginx-1.17.5.tar.gz
cd nginx-1.17.5
./configure \
--sbin-path=/usr/local/nginx/nginx \
--conf-path=/usr/local/nginx/nginx.conf \
--pid-path=/usr/local/nginx/nginx.pid \
--with-pcre=/usr/local/src/pcre-8.43 \
--with-zlib=/usr/local/src/zlib-1.2.11 \
--with-http_ssl_module \
--with-openssl=/usr/local/src/openssl-1.1.1d
make
make install

# nginx settings
ln -s /usr/local/nginx/nginx /usr/local/sbin/nginx
cd /usr/local/nginx
# cpu logic core amount
processors=`cat /proc/cpuinfo | grep 'processor' | wc -l`
sed -i -e '3d' nginx.conf
sed -i -e "2a worker_processes  ${processors};" nginx.conf
sed -i -e '65,71s/#//' nginx.conf

# these will change the line number
sed -i -e "3a worker_cpu_affinity auto;" nginx.conf

