#!/bin/bash
curl -O http://ftp.cl.debian.org/debian/pool/main/m/mysql-utilities/mysql-utilities_1.6.4-1_all.deb
apt-get update && apt install -y ./mysql-utilities_1.6.4-1_all.deb
cd /bitnami/mysql/data
chown -R 1001 database/
cd database/
echo 'CREATE DATABASE recover;' | mysql
FRM_FILES="";for file in *.ibd;do FRM_FILES="$FRM_FILES ${file%.*}.frm";done
{ mysqlfrm --server=root2@localhost --port=3307 --user=root $FRM_FILES 2> /dev/null || mysqlfrm --diagnostic $FRM_FILES; } | grep -v "#" | awk 'BEGIN {RS = "\n\n"} {print $0";"}' > /tmp/dump.sql
mysql recover < /tmp/dump.sql
echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE `", TABLE_SCHEMA,"`.`", TABLE_NAME, "` DISCARD TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql
/bin/cp -a ./* ../recover/
echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE `", TABLE_SCHEMA,"`.`", TABLE_NAME, "` IMPORT TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql
mysqldump recover > /recover.sql
exit