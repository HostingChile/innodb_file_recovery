# Restauracion de InnoDB a partir de los archivos

### Importante
Este método no garantiza la recuperación de toda la información. Por ejemplo no se recupera la información de llaves foráneas ni tampoco la secuencia de auto incrementales.

### Requisitos
Instalar Docker y Docker Compose

### Procedimiento
Copiar el contenido de la carpeta de la base de datos del cliente en la carpeta **database** y luego ejecutar los comandos del listado:

* `docker-compose up -d --force-recreate`
* `docker cp database mysql:/bitnami/mysql/data`
* `docker-compose exec --user=root mysql /recover.sh` o `docker-compose exec --user=root mysql /recover.sh --diagnostic`
* `docker cp mysql:/recover.sql ./recover.sql`

Esto generará el archivo **recover.sql** el cual es un dump de la base de datos.