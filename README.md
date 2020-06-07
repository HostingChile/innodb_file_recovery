# Restauracion de InnoDB a partir de los archivos

### Importante
Este método no garantiza la recuperación de toda la información. Por ejemplo no se recupera la información de llaves foráneas ni tampoco la secuencia de auto incrementales.

### Requisitos
Instalar Docker y Docker Compose

### Procedimiento
Copiar el contenido de la carpeta de la base de datos del cliente en la carpeta **database** y luego ejecutar los comandos del listado:

* docker-compose up -d --force-recreate
* docker cp database mysql:/bitnami/mysql/data
* docker-compose exec --user=root mysql bash
* curl -O http://ftp.cl.debian.org/debian/pool/main/m/mysql-utilities/mysql-utilities_1.6.4-1_all.deb
* apt-get update && apt install -y ./mysql-utilities_1.6.4-1_all.deb
* cd /bitnami/mysql/data
* chown -R 1001 database/
* cd database/
* echo 'CREATE DATABASE recover;' | mysql
* FRM_FILES="";for file in \*.ibd;do FRM_FILES="$FRM_FILES ${file%.\*}.frm";done
* mysqlfrm --server=root@localhost --port=3307 --user=root $FRM_FILES | grep -v "#" | awk 'BEGIN {RS = "\n\n"} {print $0";"}' > /tmp/dump.sql
  * (EN CASO DE ERROR) mysqlfrm --server=root@localhost --port=3307 --user=root --diagnostic $FRM_FILES | grep -v "#" > /tmp/dump.sql
* mysql recover < /tmp/dump.sql
* echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE \`", TABLE_SCHEMA,"\`.\`", TABLE_NAME, "\` DISCARD TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql
* /bin/cp -a ./* ../recover/
* exit
* docker restart mysql
* docker-compose exec --user=root mysql bash
* echo 'USE INFORMATION_SCHEMA; SELECT CONCAT("ALTER TABLE \`", TABLE_SCHEMA,"\`.\`", TABLE_NAME, "\` IMPORT TABLESPACE;") AS MySQLCMD FROM TABLES WHERE TABLE_SCHEMA = "recover" AND ENGINE = "InnoDB";' | mysql -N | xargs | mysql
* mysqldump recover > /recover.sql
* exit 
* docker cp mysql:/recover.sql .

Esto generará el archivo **recover.sql** el cual es un dump de la base de datos.