#!/bin/sh

yum install -y libxml2-devel openssl openssl-devel bzip2-devel curl-devel libjpeg-devel \
libpng-devel freetype-devel gcc-c++ autoconf unzip pcre-devel libmcrypt-devel mhash-devel

cd /usr/local/src
# cmake for installing libzip
# rc but it's ok just a tool
wget https://github.com/Kitware/CMake/releases/download/v3.16.0-rc3/cmake-3.16.0-rc3.tar.gz
tar -zxf cmake-3.16.0-rc3.tar.gz
cd cmake-3.16.0-rc3
./configure
make
make install

# libzip
cd /usr/local/src
wget https://libzip.org/download/libzip-1.5.2.tar.gz
tar -zxf libzip-1.5.2.tar.gz
cd libzip-1.5.2
mkdir build
cd build
cmake ..
make
make install

# setting
echo '' >> /etc/ld.so.conf
echo -e '/usr/local/lib64\n/usr/local/lib\n/usr/lib\n/usr/lib64' >> /etc/ld.so.conf
ldconfig -v

# pecl
cd /usr/local/src
# redis
wget https://pecl.php.net/get/redis-5.0.2.tgz
tar -zxf redis-5.0.2.tgz
# mcrypt
wget https://pecl.php.net/get/mcrypt-1.0.3.tgz
tar -zxf mcrypt-1.0.3.tgz

# download php
cd /usr/local/src
wget https://www.php.net/distributions/php-7.3.11.tar.gz
tar -zxf php-7.3.11.tar.gz
# move
mv redis-5.0.2 php-7.3.11/ext/redis
mv mcrypt-1.0.3 php-7.3.11/ext/mcrypt
# install php
cd php-7.3.11
rm -f configure
./buildconf --force
./configure \
--prefix=/usr/local/php \
--enable-fpm \
--with-mcrypt \
--enable-mbstring \
--with-pdo-mysql \
--with-curl \
--disable-rpath \
--with-bz2  \
--with-zlib \
--enable-sockets \
--enable-sysvsem \
--enable-sysvshm \
--enable-pcntl \
--with-mhash \
--with-libzip \
--enable-zip \
--with-pcre-regex \
--with-mysqli \
--with-gd \
--with-jpeg-dir \
--with-openssl \
--with-gettext \
--enable-redis
make
make install
# link
ln -s /usr/local/php/bin/php /usr/local/bin/php
ln -s /usr/local/php/bin/php-config /usr/local/bin/php-config
ln -s /usr/local/php/bin/phpize /usr/local/bin/phpize
ln -s /usr/local/php/sbin/php-fpm /usr/local/sbin/php-fpm
# install phalcon
cd /usr/local/src
wget https://github.com/phalcon/cphalcon/archive/3.4.x.zip -O cphalcon-3.4.x.zip
unzip cphalcon-3.4.x.zip
cd /usr/local/src/cphalcon-3.4.x/build
./install
# setting
cd /usr/local/php
cp /usr/local/src/php-7.3.11/php.ini-production lib/php.ini-production
cp /usr/local/src/php-7.3.11/php.ini-development lib/php.ini
# development
sed -i -e "905a zend_extension=opcache.so" lib/php.ini
sed -i -e "905a extension=phalcon.so" lib/php.ini
# production & optimize
sed -i -e "907a zend_extension=opcache.so" lib/php.ini-production
sed -i -e "907a extension=phalcon.so" lib/php.ini-production
# opcache.enable=1
# opcache.huge_code_pages=1
sed -i -e 's#opcache.file_cache=#opcache.file_cache=/tmp#' lib/php.ini-production
echo 'vm.nr_hugepages=512' >> /etc/sysctl.conf
sysctl -p
# in production env replace php.ini with php.ini-production
# mv lib/php.ini lib/php.ini-developement
# mv lib/php.ini-production /lib/php.ini

cp etc/php-fpm.conf.default etc/php-fpm.conf
cp etc/php-fpm.d/www.conf.default etc/php-fpm.d/www.conf

php -m
echo "Don't forget to set the process manager and user."

# phalcon requires system reboot
for((i=5;i>0;i--))
do
echo "System will reboot in ${i}s"
sleep 1
done
shutdown -r now
