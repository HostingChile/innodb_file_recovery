#!/bin/bash

# Install mysql-utilities
curl -O http://ftp.cl.debian.org/debian/pool/main/m/mysql-utilities/mysql-utilities_1.6.4-1_all.deb
apt-get update && apt install -y ./mysql-utilities_1.6.4-1_all.deb

# Fix permissions
chown -R 1001 /bitnami/mysql/data/database

# Run mysqlfrm
cd /bitnami/mysql/data/database
FRM_FILES="";for file in *.ibd;do FRM_FILES="$FRM_FILES ${file%.*}.frm";done
if [ "$1" == "--diagnostic" ]; then
  mysqlfrm --diagnostic $FRM_FILES
else
  mysqlfrm --server=root@localhost --port=3307 --user=root $FRM_FILES
fi | grep -v "#" | awk 'BEGIN {RS = "\n\n"} {print $0";"}' > /tmp/dump.sql

# Create database and tables
echo 'CREATE DATABASE recover;' | mysql
mysql recover < /tmp/dump.sql

# Recover tables data
echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE `", TABLE_SCHEMA,"`.`", TABLE_NAME, "` DISCARD TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql
/bin/cp -a ./* ../recover/
echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE `", TABLE_SCHEMA,"`.`", TABLE_NAME, "` IMPORT TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql

# Create sqldump
mysqldump recover > /recover.sql