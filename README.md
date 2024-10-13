# ECom
# 1. Ejecución
## 1.1 Ejecución Docker
Se recomienda ejecutar en un contenedor Docker. Esto evita tener que instalar y configurar manualmente la BD, Ruby, etc.

**Pre-requisitos**
- Docker
- Docker Compose

La configuración de Docker Compose fue probada en la distribución ArchLinux.

Iniciar la aplicación
````sh
$ docker-compose up dev
````
Acceder a http://localhost:3000

Ctrl + c para detener la aplicación en la Terminal.

También se puede iniciar la aplicación en segundo plano
````sh
$ docker-compose up dev -d
````

En este caso la aplicación se detiene con
````sh
$ docker-compose down
````

### Aclaraciones
Los usuarios de prueba para acceder a la aplicación son:
- amy-admin@email.com
- bob-admin@email.com
- john-client@email.com
- dean-client@email.com

Todos los usuarios tienen la contraseña 12345

Los usuarios con -client son clientes y solo pueden comprar y ver sus compras

Los usuarios con -admin son administradores y pueden ver todo

Desde la aplicación sólo se pueden registrar usuarios de tipo cliente

Más usuarios de tipo admin deben agregarse en el seed en el método create_users

Para el envío de email de primera compra se debe especificar SMPT_USER_NAME y SMPT_PASSWORD en caso de que se use gmail, 
si se usa algún otro se debe cambiar el resto de las variables que empiezan con SMTP. También es necesario agregar al seed
un email válido para los usuarios admin para que pueda recibirse el correo. De igual modo en el log de la aplicación se
puede comprobar la construcción del email.

La información de quienes crearon o actualizaron productos y categorias se guardan en la tabla versions. No se implementó
una vista para ver esta información.

El diagrama ER se encuentra en la carpeta doc

En la sección reportes accediendo como usuario admin se muestran las instrucciones para comprobar la autenticación JWT.

Como usuario admin, algunas filas del listado de ventas y productos están marcadas en celeste, esto indica que el producto
en cuestión fue registrado por el usuario actual. Lo hice así para facilitar su identificación

## 1.2 Ejecución Local
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

# 2. Testing
## 2.1 Testing Docker
Ejecutar los tests
````sh
$ docker-compose up test
````

## 2.2 Testing Local
Ejecutar los tests
````sh
$ rake spec
````

# 3. Depuración
## 3.1. Depuración Rubymine
Habilitar el comando de depuración en docker-compose
````yml
command: rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- script/rails s -b 0.0.0.0
````

Agregar una configuración de depuración remota en Rubymine
![img.png](doc/others/ruby_remote_debug.png)

- `Remote host`: Es localhost porque se expuso el puerto 1234 al host local a través en docker-compose
- `Remote port`: El port indicado al comando rdebug-ide
- `Remote root folder`: La ubicación en donde está el código fuente dentro del contenedor, esta ubicación está definida en docker-compose
- `Local port`: El dispatcher-port indicado al comando rdebug-ide
- `Local root folder`: La ubicación del código fuente en el host

Iniciar la aplicación desde la terminal
````sh
$ docker-compose up test
````

Ejecutar "Debug Docker Rails" en Rubymine

![img.png](doc/others/debug_docker_rails.png)

# 4. Comandos Útiles
Iniciar e ingresar al contenedor sin ejecutar rails s por defecto. Útil para resetear la base de datos.
````sh
$ docker-compose run --rm -p 3000:3000 dev /bin/bash
````
- `rm`: el contenedor desaparece al salir del mismo.
- `-p 3000:3000`: expone el puerto 3000 del contenedor al puerto 3000 del host.

Desde el contenedor se puede ejecutar rails s lo cual es más útil para analizar los logs durante la ejecución
y apagar y prender más rápido el servidor

Ejecutar todos los tests dentro del contenedor
````sh
$ rake spec
````

Ejecutar un archivo de tests en particular dentro del contenedor
````sh
$ rspec spec/controllers/products_controller_spec.rb
````

Ejecutar brakeman dentro del contenedor
````sh
$ brakeman -o brakeman_results.html
````
