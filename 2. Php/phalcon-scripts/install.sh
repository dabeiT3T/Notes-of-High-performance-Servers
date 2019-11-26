#!/bin/sh

HOME_PATH=`pwd`

# user setting
useradd -r developer
useradd -G developer dabei
useradd -G developer git
useradd -r -G developer nginx
useradd -r -G developer php
echo 'Enter password for user dabei:'
passwd dabei

su git -c 'ssh-keygen'

# yum
yum install -y yum install -y libxml2-devel openssl openssl-devel bzip2-devel curl-devel libjpeg-devel \
libpng-devel freetype-devel gcc-c++ autoconf unzip pcre-devel libmcrypt-devel mhash-devel wget

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
wget https://www.openssl.org/source/openssl-1.1.1d.tar.gz
tar -zxf openssl-1.1.1d.tar.gz
# will not install, php-fpm will use openssl installed by yum

# nginx
cd /usr/local/src
wget https://nginx.org/download/nginx-1.17.6.tar.gz
tar -zxf nginx-1.17.6.tar.gz
cd nginx-1.17.6
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
# copy nginx conf
cd /usr/local/nginx
cp ${HOME_PATH}/config/nginx.conf ./nginx.conf
chmod 644 nginx.conf

# cpu logic core amount
processors=`cat /proc/cpuinfo | grep 'processor' | wc -l`
sed -i -e '3d' nginx.conf -e "2a worker_processes  ${processors};" nginx.conf

cd /usr/local/src
# cmake for installing libzip
# rc but it's ok just a tool
wget https://github.com/Kitware/CMake/releases/download/v3.16.0-rc4/cmake-3.16.0-rc4.tar.gz
tar -zxf cmake-3.16.0-rc4.tar.gz
cd cmake-3.16.0-rc4
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
wget https://pecl.php.net/get/redis-5.1.1.tgz
tar -zxf redis-5.1.1.tgz
# mcrypt
wget https://pecl.php.net/get/mcrypt-1.0.3.tgz
tar -zxf mcrypt-1.0.3.tgz

# download php
cd /usr/local/src
wget https://www.php.net/distributions/php-7.3.12.tar.gz
tar -zxf php-7.3.12.tar.gz
# move
mv redis-5.1.1 php-7.3.12/ext/redis
mv mcrypt-1.0.3 php-7.3.12/ext/mcrypt
# install php
cd php-7.3.12
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

cp ${HOME_PATH}/config/php.ini-production lib/php.ini-production
cp ${HOME_PATH}/config/php.ini lib/php.ini
# hugepages
echo 'vm.nr_hugepages=512' >> /etc/sysctl.conf
sysctl -p
# in production env replace php.ini with php.ini-production
# mv lib/php.ini lib/php.ini-developement
# mv lib/php.ini-production /lib/php.ini
# php-fpm setting
cp ${HOME_PATH}/config/php-fpm.conf etc/php-fpm.conf
cp ${HOME_PATH}/config/www.conf etc/php-fpm.d/www.conf
let processors4PHP=processors*2
# pm = static & pm.max_children = 2*cpu logic amount
sed -i "113s/5/${processors4PHP}/" etc/php-fpm.d/www.conf
# set sock
mkdir /run/php
chown php:developer /run/php
mkdir /run/php/
php-fpm
chmod php:developer /run/php/php7.2-fpm.sock

# composer
cd ~
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
composer config -g repo.packagist composer https://packagist.phpcomposer.com

# git version on yum is old
cd /usr/local/src
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.24.0.tar.gz
tar -zxf git-2.24.0.tar.gz
cd git-2.24.0
./configure
make
make install

# phalcon-tool
#cd /usr/local/src
#git clone git://github.com/phalcon/phalcon-devtools.git
#ln -s /usr/local/src/phalcon-devtools/phalcon /usr/local/bin/phalcon
# add project
mv ${HOME_PATH}/phalcon /srv/phalcon
mv ${HOME_PATH}/umask.sh /srv/umask.sh
cd /srv
chmod 770 umask.sh
./umask.sh

# set git
cd ~git
cat .ssh/id_rsa.pub >> .ssh/authorized_keys
chown git:git .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
su git -c 'git init --bare phalcon.git'
mv phalcon.git/hooks/post-update.sample phalcon.git/hooks/post-update
echo "cd /srv/phalcon" >> phalcon.git/hooks/post-update
echo "env -i git pull" >> phalcon.git/hooks/post-update

# add project to phalcon.git
# auto add ECDSA to the list of know hosts
sed -i "s/#   StrictHostKeyChecking ask/   StrictHostKeyChecking no/" /etc/ssh/ssh_config
su git -c 'git clone git@127.0.0.1:~/phalcon.git'
sed -i "s/   StrictHostKeyChecking no/#   StrictHostKeyChecking ask/" /etc/ssh/ssh_config
mv phalcon/.git /srv/phalcon/.git
rm -rf phalcon
# set git config
su git -c 'git config --global user.email "git@localhost"'
su git -c 'git config --global user.name "git"'
su git -c 'git config --global push.default simple'
# git push
cd /srv/phalcon
su git -c 'git add .'
su git -c 'git commit init'
su git -c 'git push'
# git no bash
sed -r -i 's#^(git:x:[0-9]{,4}:[0-9]{,4}:[a-z]{,10}:/home/git:)(.*)#\1/usr/bin/git-shell#' /etc/passwd

# show modules
php -m

# phalcon requires system reboot
for((i=5;i>0;i--))
do
echo "System will reboot in ${i}s"
sleep 1
done
shutdown -r now
