# Restauracion de InnoDB a partir de los archivos

En caso de que el servidor MySQL de origen **NO** tenga la opción `innodb_file_per_table` habilitada (`echo "SHOW VARIABLES LIKE 'innodb_file_per_table'" | mysql`), la información de las tablas estará en los archivos ib* (ib_logfile0, ib_logfile1 e ibdata), por lo tanto habría que restaurar estos archivos en conjunto con la información de las BBDD. En caso contrario se puede seguir este procedimiento para restaurar usando `mysqlfrm` (https://docs.oracle.com/cd/E17952_01/mysql-utilities-1.4-en/mysqlfrm.html)

### Importante
Este método no garantiza la recuperación de toda la información. Por ejemplo no se recupera la información de llaves foráneas ni tampoco la secuencia de auto incrementales.

### Procedimiento
Copiar el contenido de la carpeta de la base de datos (archivos .frm, .MYD, .MYI, .ibd) del cliente en la carpeta **database** y luego ejecutar los comandos del listado:

* `docker-compose up -d --force-recreate`
* `docker cp database mysql_recover:/bitnami/mysql/data` (no se puede montar la carpeta en el docker-compose.yml porque la imagen borra su contenido)
* `docker-compose logs -f mysql_recover`
* `docker-compose exec --user=root mysql_recover /recover.sh` o `docker-compose exec --user=root mysql_recover /recover.sh --diagnostic`
* `docker cp mysql_recover:/recover.sql ./recover.sql`
* `docker-compose down`

Esto generará el archivo **recover.sql** el cual contiene un dump de la base de datos.