#!/bin/sh

yum install -y wget pcre-devel openssl-devel gcc curl perl make unzip patch

cd /usr/local/src
wget http://zlib.net/zlib-1.2.11.tar.gz
tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
make install

cd /usr/local/src
wget https://www.openssl.org/source/openssl-1.0.2t.tar.gz
tar -zxf openssl-1.0.2t.tar.gz

wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz
tar -zxf ngx_cache_purge-2.3.tar.gz

wget https://github.com/xiaokai-wang/nginx_upstream_check_module/archive/master.zip \
-O ./nginx_upstream_check_module-master.zip
unzip nginx_upstream_check_module-master.zip

wget https://github.com/weibocom/nginx-upsync-module/archive/master.zip \
-O ./nginx-upsync-module-master.zip
unzip nginx-upsync-module-master.zip

wget https://openresty.org/download/openresty-1.15.8.2.tar.gz
tar -zxf openresty-1.15.8.2.tar.gz

cd /usr/local/src/openresty-1.15.8.2
./configure \
--prefix=/usr/local/openresty \
--with-pcre \
--with-zlib=/usr/local/src/zlib-1.2.11 \
--with-openssl=/usr/local/src/openssl-1.0.2t/ \
--with-http_realip_module \
--with-luajit \
--add-module=/usr/local/src/ngx_cache_purge-2.3/ \
--add-module=/usr/local/src/nginx_upstream_check_module-master/ \
--add-module=/usr/local/src/nginx-upsync-module-master/ \
-j2

cd /usr/local/src/openresty-1.15.8.2/build/nginx-1.15.8
patch -p1 < /usr/local/src/nginx_upstream_check_module-master/check_1.12.1+.patch

cd /usr/local/src/openresty-1.15.8.2
make
make install

ln -s /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx

sed -i -e "33a\    lua_package_path '/usr/local/openresty/lualib/?.lua;;';" \
/usr/local/openresty/nginx/conf/nginx.conf
sed -i -e "34a\    lua_package_cpath '/usr/local/openresty/lualib/?.so;;';" \
/usr/local/openresty/nginx/conf/nginx.conf

exit 0
