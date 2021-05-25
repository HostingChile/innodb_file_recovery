#!/bin/bash

while true; do
  mysqladmin ping --silent && break || { echo "Waiting for mysql" && sleep 1; }
done

echo "Starting recovery process"

# Fix permissions
chown -R 1001 /bitnami/mysql/data/database

# Run mysqlfrm
[ -d /bitnami/mysql/data/database ] || { echo "No database files copied to the container" && exit 1; }
cd /bitnami/mysql/data/database
FRM_FILES="";for file in *.ibd;do FRM_FILES="$FRM_FILES ${file%.*}.frm";done

echo "Generating tables structure"

if [ "$1" == "--diagnostic" ]; then
  mysqlfrm --diagnostic $FRM_FILES
else
  mysqlfrm --server=root@localhost --port=3307 --user=root $FRM_FILES
fi | grep -v "#" | awk 'BEGIN {RS = "\n\n"} {print $0";"}' > /tmp/dump.sql

# Create database and tables
echo 'DROP DATABASE recover;' | mysql > /dev/null 2>&1
echo 'CREATE DATABASE recover;' | mysql
echo 'SET GLOBAL sql_mode = "";' | mysql

echo "Importing tables structure"

mysql recover < /tmp/dump.sql

# Recover tables data
echo "Recovering data"
echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE `", TABLE_SCHEMA,"`.`", TABLE_NAME, "` DISCARD TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql
/bin/cp -a ./* ../recover/
echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE `", TABLE_SCHEMA,"`.`", TABLE_NAME, "` IMPORT TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql

# Create sqldump
mysqldump recover -f > /recover.sql
echo "Done"