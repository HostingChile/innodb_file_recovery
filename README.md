# Restauracion de InnoDB a partir de los archivos

Copiar el contenido de la carpeta de la base de datos del cliente en la carpeta database y luego ejecutar los comandos del listado:

* docker-compose up -d --force-recreate
* docker cp database mysql:/var/lib/mysql
* docker-compose exec mysql bash
* curl -O https://repo.mysql.com/yum/mysql-connectors-community/el/7/x86_64/mysql-connector-python-2.0.4-1.el7.noarch.rpm
* curl -O https://repo.mysql.com/yum/mysql-tools-community/el/7/x86_64/mysql-utilities-1.6.5-1.el7.noarch.rpm
* yum localinstall -y mysql-connector-python-2.0.4-1.el7.noarch.rpm mysql-utilities-1.6.5-1.el7.noarch.rpm
* cd /var/lib/mysql
* chown -R mysql:mysql database/
* cd database/
* echo 'CREATE DATABASE recover;' | mysql
* FRM_FILES="";for file in \*.ibd;do FRM_FILES="$FRM_FILES ${file%.\*}.frm";done
* mysql recover < <(mysqlfrm --server=root:password@localhost --port=3307 --user=mysql --diagnostic $FRM_FILES | grep -v "^#" | tail -n +2)
* echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE \`", TABLE_SCHEMA,"\`.\`", TABLE_NAME, "\` DISCARD TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql
* /bin/cp -a ./* ../recover/
* exit
* docker restart mysql
* docker-compose exec mysql bash
* echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE \`", TABLE_SCHEMA,"\`.\`", TABLE_NAME, "\` IMPORT TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql
* mysqldump recover > recover.sql
* exit 
* docker cp mysql:/recover.sql .