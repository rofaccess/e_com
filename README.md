# ECom
# Ejecución
## Ejecución Docker
Se recomienda ejecutar en un contenedor Docker. Esto evita tener que instalar y configurar manualmente la BD, Ruby, etc.

**Pre-requisitos**
- Docker
- Docker Compose

La configuración de Docker Compose fue probada en la distribución ArchLinux.

Iniciar la aplicación
````sh
$ docker-compose up
````
Acceder a http://localhost:3000

Detener la aplicación
````sh
$ docker-compose down
````

## Ejecución Local
**Pre-requisitos**
- Ruby 1.9.3
- PostgreSQL 9.6
- Redis

Ubicarse en el directorio del proyecto Rails e instalar las gemas
````sh
$ bundle install
````
Crear el usuario de base de datos en PostgreSQL
````sh
$ sudo su postgres
$ psql
postgres=# create role e_com with CREATEDB SUPERUSER login password 'e_com';
postgres=# \q
$ exit
````

Iniciar la base de datos, ejecutar migraciones y seed.
````sh
$ rake db:setup
````

Iniciar la aplicación
````sh
$ rails s
````
Acceder a http://localhost:3000
