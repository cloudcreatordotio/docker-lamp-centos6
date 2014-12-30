#!/usr/bin/env bash

# php session
mkdir -m 777 -p /srv/php/session
echo "tmpfs /srv/php/session tmpfs size=32m,mode=700,uid=daemon,gid=daemon 0 0" >> /etc/fstab
mount /srv/php/session

# php upload_tmp_dir
mkdir -m 777 -p /srv/php/upload_tmp_dir

service mysqld start

# create database & tables
#mysql --defaults-extra-file=/root/.my.cnf < schema/create_database.sql
#mysql --defaults-extra-file=/root/.my.cnf nakamino < schema/create_tables.sql

#
# Run container foreground
#

# supervisor
/usr/bin/supervisord
