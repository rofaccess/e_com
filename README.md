# ECom
# 1 Ejecución
## 1.1 Ejecución Docker
Se recomienda ejecutar en un contenedor Docker. Esto evita tener que instalar y configurar manualmente la BD, Ruby, etc.

Más información sobre el uso de Docker en [Docker Basics](doc/docker_basics.md) y [Docker Rails](doc/docker_rails.md).


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

## 1.2 Características del proyecto
### 1.2.1 Usuarios
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

### 1.2.2 Envío de correo

Cuando se realiza la primera compra de un producto, se envía un correo al administrador que registró el producto con copia
a los otros administradores. Este correo se envía utilizando un proceso en segundo plano con sidekiq. Se utiliza sidekiq
para evitar que un efecto de cuelgue al realizar la primera compra.

Para el envío de email debe especificar SMPT_USER_NAME y SMPT_PASSWORD en caso de que se use gmail, 
si se usa algún otro se debe cambiar el resto de las variables que empiezan con SMTP. También es necesario agregar al seed
un email válido para los usuarios admin para que pueda recibirse el correo. De igual modo en el log de la aplicación se
puede comprobar la construcción del email.

### 1.2.3 Log de auditoría
Se registra el administrador que crea o actualiza productos y categorías.

Esta información se guarda en la tabla versions. No se implementó una vista para ver esta información.

### 1.2.4 ER Diagram
Se diseño un diagrama ER el cual se encuentra en la carpeta doc.

### 1.2.5 Autenticación JWT
Se usa JWT para autenticar a los usuarios administradores que se conectan a las APIs.

En la sección reportes accediendo como usuario admin se muestran las instrucciones para comprobar la autenticación JWT.

### 1.2.6 APIs
Se implementaron algunas APIs. 
Cada API recibe parámetros para limitar el resultado.
Para acceder a las Apis se debe pasarle un token de autenticación JWT a la petición.
Este token se construye en base al id del usuario y un token guardado en el archivo .env.
Se puede ver el listado de APIs disponibles accediendo a http://localhost:3000/reports. En esta pantalla también se
muestra el token en base al usuario admin logueado. En esta pantalla también se especifican los parámetros permitidos
para cada API.

**Obs.:** No se implementó un API para obtener el token de autorización. Para obtener el token hay que loguearse a la
aplicación como usuario admin y acceder a la sección Reports.

Apis Implementadas:
1. Obtener los productos más comprados por cada categoría
````sh
curl -w '\n' -H 'Authorization: your_token' 'http://localhost:3000/api/reports/most_purchased_products_by_each_category'
````

2. Obtener los 3 productos que más han recaudado por categoría
````sh
curl -w '\n' -H 'Authorization: your_token' 'http://localhost:3000/api/reports/best_selling_products_by_each_category'
````

3. Obtener listado de ventas
````sh
curl -w '\n' -H 'Authorization: your_token' 'http://localhost:3000/api/reports/sale_orders?page=1'
````

4. Obtener cantidad de ventas por día, mes o año.
````sh
curl -w '\n' -H 'Authorization: your_token' 'http://localhost:3000/api/reports/sale_orders_quantity?granularity=year'
````

### 1.2.7 Otros
Como usuario admin, algunas filas del listado de ventas y productos están marcadas en celeste, esto indica que el producto
en cuestión fue registrado por el usuario actual. Lo hice así para facilitar su identificación

## 1.3 Ejecución Local
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

Ejecutar el seed manualmente (En el entrypoint ya se ejecuta, aunque posiblemente lo quite del entrypoint en algún momento)
````sh
$ docker-compose run --rm dev rake db:seed
````
- `rm`: el contenedor desaparece al salir del mismo.
- `-p 3000:3000`: expone el puerto 3000 del contenedor al puerto 3000 del host.

Ejecutar todos los tests dentro del contenedor
````sh
$ rake spec
````

Ejecutar un archivo de tests en particular dentro del contenedor.
````sh
$ RAILS_ENV=test rspec spec/controllers/products_controller_spec.rb
$ RAILS_ENV=test bundle exec rspec spec/controllers/products_controller_spec.rb # Alternativa
````
Es importante indicar el environment en el contenedor de dev, porque osino realizará cambios en la base de datos de development
rake spec no necesita que se le indique el environment
Si fuera el contenedor de test no haría falta indicar el environment a rspec

Ejecutar brakeman dentro del contenedor
````sh
$ brakeman -o brakeman_results.html
````

Comprobar si redis se está ejecutando. Ver los logs de ejecución de servicios
````sh
$ docker-compose logs redis
$ docker logs e_com-redis-1 # Alternativa
$ docker-compose logs sidekiq
````
