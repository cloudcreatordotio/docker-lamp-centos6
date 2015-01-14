FROM centos:centos6
MAINTAINER yutaf <fujishiro@amaneku.co.jp>

#
# yum repos
#
# epel
# need for libcurl-devel
RUN yum localinstall http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -y
# mysql
RUN yum localinstall https://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm -y
# ius
RUN yum localinstall -y http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-13.ius.centos6.noarch.rpm


RUN yum update -y
RUN yum install --enablerepo=epel,mysql56-community,ius -y \
# Apache, php \
  tar \
  gcc \
  zlib \
  zlib-devel \
  openssl-devel \
  pcre-devel \
# use 'which' in php programm
  which \
# git by ius
# 2014/11/12 not available
#  git18 \
  git \
# php \
  perl \
  libxml2-devel \
  libjpeg-devel \
  libpng-devel \
  freetype-devel \
  libmcrypt-devel \
  libcurl-devel \
  readline-devel \
  libicu-devel \
  gcc-c++ \
# mysql
  mysql-server \
# supervisor
  supervisor \
# cron
  crontabs.noarch

#
# Apache
#

ADD http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/httpd/httpd-2.2.29.tar.gz /usr/local/src/
RUN cd /usr/local/src && \
  tar xzvf httpd-2.2.29.tar.gz && \
  cd httpd-2.2.29 && \
    ./configure \
      --prefix=/opt/apache2.2.29 \
      --enable-mods-shared=all \
      --enable-proxy \
      --enable-ssl \
      --with-ssl \
      --with-mpm=prefork \
      --with-pcre

# install
RUN cd /usr/local/src/httpd-2.2.29 && \
  make && make install

# check appche running with default document root
#RUN echo 'Hello, vagrant docker provider' > /opt/apache2.2.29/htdocs/index.html

#
# php
#

ADD http://jp2.php.net/get/php-5.6.4.tar.gz/from/this/mirror /usr/local/src/php-5.6.4.tar.gz

RUN cd usr/local/src && \
  tar xzvf php-5.6.4.tar.gz && \
  cd php-5.6.4 && \
  ./configure \
    --prefix=/opt/php-5.6.4 \
    --with-config-file-path=/srv/php \
    --with-apxs2=/opt/apache2.2.29/bin/apxs \
    --with-libdir=lib64 \
    --enable-mbstring \
    --enable-intl \
    --with-icu-dir=/usr \
    --with-gettext=/usr \
    --with-pcre-regex=/usr \
    --with-pcre-dir=/usr \
    --with-readline=/usr \
    --with-libxml-dir=/usr/bin/xml2-config \
    --with-mysql=mysqlnd \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-zlib=/usr \
    --with-zlib-dir=/usr \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-freetype-dir=/usr \
    --enable-gd-native-ttf \
    --enable-gd-jis-conv \
    --with-openssl=/usr \
    --with-mcrypt=/usr \
    --enable-bcmath \
    --with-curl \
    --enable-exif

# install
RUN cd /usr/local/src/php-5.6.4 && \
  make && make install

# set php PATH
ENV PATH /opt/php-5.6.4/bin:$PATH

#
# xdebug
#
RUN cd /usr/local/src && \
  git clone git://github.com/xdebug/xdebug.git && \
  cd xdebug && \
  phpize && \
  ./configure --enable-xdebug && \
  make && \
  make install

# php.ini
COPY templates/php.ini /srv/php/
RUN echo 'zend_extension = "/opt/php-5.6.4/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so"' >> /srv/php/php.ini


#
# Edit config files
#

# Apache config
RUN sed -i "s/^Listen 80/#&/" /opt/apache2.2.29/conf/httpd.conf && \
  sed -i "s/^DocumentRoot/#&/" /opt/apache2.2.29/conf/httpd.conf && \
  sed -i "/^<Directory/,/^<\/Directory/s/^/#/" /opt/apache2.2.29/conf/httpd.conf && \
  sed -i "s;ScriptAlias /cgi-bin;#&;" /opt/apache2.2.29/conf/httpd.conf && \
  sed -i "s;#\(Include conf/extra/httpd-mpm.conf\);\1;" /opt/apache2.2.29/conf/httpd.conf && \
  sed -i "s;#\(Include conf/extra/httpd-default.conf\);\1;" /opt/apache2.2.29/conf/httpd.conf && \
# DirectoryIndex; index.html precedes index.php
  sed -i "/\s*DirectoryIndex/s/$/ index.php/" /opt/apache2.2.29/conf/httpd.conf && \
  sed -i "s/\(ServerTokens \)Full/\1Prod/" /opt/apache2.2.29/conf/extra/httpd-default.conf && \
  echo "Include /srv/apache/apache.conf" >> /opt/apache2.2.29/conf/httpd.conf
COPY templates/apache.conf /srv/apache/apache.conf
RUN echo 'CustomLog "|/opt/apache2.2.29/bin/rotatelogs /srv/www/logs/access/access.%Y%m%d.log 86400 540" combined' >> /srv/apache/apache.conf && \
  echo 'ErrorLog "|/opt/apache2.2.29/bin/rotatelogs /srv/www/logs/error/error.%Y%m%d.log 86400 540"' >> /srv/apache/apache.conf && \
  mkdir -m 777 -p /srv/www/logs/{access,error}

# make Apache document root & Add a file
COPY www/htdocs/index.php /srv/www/htdocs/

# mysql config
COPY templates/my.cnf /etc/mysql/my.cnf
RUN mkdir -p -m 777 /var/tmp/mysql && \
# alternative to　"mysql_secure_installation"
  /etc/init.d/mysqld start && \
#TODO command below issues 'Warning: Using a password on the command line interface can be insecure.'
#TODO http://qiita.com/cs_sonar/items/d4a0534a0eaeb93b3215
  mysqladmin -u root password "ai3Yut4x" && \
  echo "[client]"             >> /root/.my.cnf && \
  echo "user = root"          >> /root/.my.cnf && \
  echo "password = ai3Yut4x"  >> /root/.my.cnf && \
  echo "host = localhost"     >> /root/.my.cnf && \
  chmod 600 /root/.my.cnf && \
  mysql --defaults-extra-file=/root/.my.cnf -e "DELETE FROM mysql.user WHERE User='';" && \
  mysql --defaults-extra-file=/root/.my.cnf -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" && \
  mysql --defaults-extra-file=/root/.my.cnf -e "DROP DATABASE IF EXISTS test;" && \
  mysql --defaults-extra-file=/root/.my.cnf -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" && \
  mysql --defaults-extra-file=/root/.my.cnf -e "FLUSH PRIVILEGES;" && \
  /etc/init.d/mysqld stop

# supervisor
COPY templates/supervisord.conf /etc/supervisord.conf
RUN echo '[program:apache2]' >> /etc/supervisord.conf && \
  echo 'command=/opt/apache2.2.29/bin/httpd -DFOREGROUND' >> /etc/supervisord.conf

# script for running container
COPY scripts/run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 80 3306
CMD ["/usr/local/bin/run.sh"]
