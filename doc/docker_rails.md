# Docker Rails
A continuación se detalla el proceso para inicializar un proyecto Rails desde un contenedor de Ruby.

## Crear proyecto Rails
### Docker de Ruby Oficial
Teniendo Ruby 1.9.3 que es una versión vieja es tedioso y puede que medio imposible instalarlo en una máqunia local hoy
día, por lo que es mejor usar un contenedor Docker.

Lo ideal es descargar una imágen oficial de Ruby ejecutando
```sh
docker pull ruby:1.9.3
```
El comando anterior muestra un error y no descarga la imagen.

[DEPRECATION NOTICE] Docker Image Format v1 and Docker Image manifest version 2, schema 1 support is disabled by default 
and will be removed in an upcoming release. Suggest the author of docker.io/library/ruby:1.9.3 to upgrade the image to 
the OCI Format or Docker Image manifest v2, schema 2. More information at https://docs.docker.com/go/deprecated-image-specs/

Como la forma oficial no funciona se tienen dos soluciones
1. Construir una imagen local usando el Dockerfile oficial
2. Utilizar otra imagen que si funcione

#### 1. Construir imagen oficial de Ruby (No funciona)
Descargar el Dockerfile oficial de
[ruby/1.9/Dockerfile at 4938a7b4b5b62c90b5d387c9c286fd7749d9499e · docker-library/ruby · GitHub](https://github.com/docker-library/ruby/blob/4938a7b4b5b62c90b5d387c9c286fd7749d9499e/1.9/Dockerfile)

```Dockerfile
FROM buildpack-deps:wheezy

ENV RUBY_MAJOR 1.9
ENV RUBY_VERSION 1.9.3-p547

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN apt-get update \
	&& apt-get install -y bison curl ruby procps \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/ruby \
	&& curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
		| tar -xjC /usr/src/ruby --strip-components=1 \
	&& cd /usr/src/ruby \
	&& autoconf \
	&& ./configure --disable-install-doc \
	&& make \
	&& apt-get purge -y bison ruby procps \
	&& apt-get autoremove -y \
	&& make install \
	&& rm -r /usr/src/ruby

# skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc

RUN gem install bundler

CMD [ "irb" ]
```

Para construir una imagen se tiene el comando
```sh
docker build -t <nombre-de-la-imagen>:<tag> <ruta-al-Dockerfile>
```
En donde
- `<nombre-de-la-imagen>`: Es el nombre que se le asignará a la imagen.
- `<tag>`: Es la etiqueta para la imagen (opcional, pero útil). Si no se proporciona, el tag por defecto será `latest`.
- `<ruta-al-Dockerfile>`: Es la ubicación del `Dockerfile`. Si se está ubicado en el mismo directorio donde se encuentra
el `Dockerfile`, se puede usar `.`.
  
Ejemplos
```sh
docker build . # Construye la imagen usando por defecto el archivo Dockerfile que se encuentre
docker build -t ruby:1.9.3 Dockerfile # Se indica un nombre con tag y el Dockerfile a utilizar
docker build -t ruby:1.9.3 . # Con el punto se le indica que utilice el archivo Dockerfile que se encuentre en el directorio actual
```

Generar la imagen ejecutando
```sh
docker build -t ruby:1.9.3 .
```
**Obs.:** Cuando se ejecuta este comando dentro del home en linux, se puede lanzar el siguiente error
error checking context: no permission to read from '/home/...'

En base a [docker build Error checking context: 'can't stat '\\?\\C:\\Users\\username\\AppData\\Local\\Application Data'' - Stack Overflow](https://stackoverflow.com/questions/41286028/docker-build-error-checking-context-cant-stat-c-users-username-appdata). 
Se de debe mover el Dockerfile a otro contexto, es decir en una carpeta dentro del home, y para evitar otros problemas, 
esta carpeta debe contener sólo el Dockerfile o en todo caso un .dockerignore. Con el .dockerignore correctamente definido, 
al parecer puede funcionar en el home también, aunque no lo probé, pero con mover el Dockerfile dentro de una carpeta vacía, 
al menos ya no tira el error.

Al volver a ejecutar comienza a tirar errores al momento de construir la imagen porque no puede actualizar debian, 
para esto cambié el valor de FROM a debian/eol:wheezy
Luego del cambio de la imagen base se tiene un error al tratar de descomprimir algo, lo que se soluciona agregando bzip2
al apt-get install. Aún así aparecen otros errores, así que descarto esta opción por ser muy tediosa.

#### 2. Docker de Ruby alternativo (Funciona)
Como no logré construir una imagen en base al Dockerfile oficial, procedo a probar una de las tantas imágenes disponibles
en Docker Hub.
```sh
docker pull corgibytes/ruby-1.9.3
```
Docker Hub: [hub.docker.com/r/corgibytes/ruby-1.9.3](https://hub.docker.com/r/corgibytes/ruby-1.9.3)

Comprobar que la imagen funciona
```sh
docker run --rm corgibytes/ruby-1.9.3 ruby -e "puts 'Hola Mundo'"
```
Esto debe mostrar la frase "Hola Mundo"

- `--rm`: Evita que se creen contenedores por cada ejecución de docker run.

Ingresar al contenedor y sincronizar una carpeta del contenedor con una carpeta del host
```sh
docker run -it --rm -v ${PWD}:/app corgibytes/ruby-1.9.3 bash
```

En donde
- `--rm`: indica que no se guardará una copia del contenedor, por lo que se eliminará luego de usarlo.
- `-it`: indica una interacción con el contenedor para enviarle comandos, básicamente permite ingresar dentro del contenedor
y poder ejecutar comandos.
- `-v`: crea un vinculo entre el directorio donde se está ejecutando el comando y un directorio dentro del contenedor (/app),
todo lo que se guarde dentro del directorio indicado aparecerá en el directorio local. A esto se le llama volumen v.

Crear un archivo para comprobar la sincronización (Una vez ingresado al contenedor)
```sh
cd /app
touch file.txt
```
El archivo file.txt debe aparecer en la ubicación donde se ejecutó el contenedor.

### Ejecutar Rails
Para ejecutar Rails se tienen estas opciones (pueden haber variantes)
1. Crear un nuevo proyecto desde cero y ejecutarlo en este contenedor.
2. Utilizar un Gemfile y Gemfile.lock existentes como base de un nuevo proyecto.

#### 1. Nuevo proyecto Rails desde cero
Ingresar al contenedor y sincronizar una carpeta del contenedor con una carpeta del host
```sh
docker run -it --rm -v ${PWD}:/app corgibytes/ruby-1.9.3 bash
```

Instalar Rails dentro del contenedor
```sh
gem install concurrent-ruby --version 1.1.9
gem install rack -v 1.6.13
gem install rack-cache --version 1.7.1
gem install thor -v 0.20.3
# Las gemas anteriores son pre-requisitos que se deben instalar antes de instalar esta versión de Rails
gem install rails --version 3.2.22.5
```

Crear el proyecto Rails
```sh
rails new blog
chmod -R 777 blog # Actualiza permisos para que se puedan realizar cambios desde el host. No es lo mas seguro dar todos los permisos, pero para este caso de prueba no importa
cd blog
rails s # Esto tira un error relativo a execjs, aún comentando las gemas problematicas desde el host, no me toma los cambios, siempre quiere instalar execjs
```

Dependiendo de la ubicación desde donde se ejecutó el contenedor, se habrá creado la carpeta blog dentro del host local. 
Si se ejecutó el contenedor en home, entonces aparecerá una carpeta blog en el home.

**Probar la aplicación Rails**

Para esto se necesita definir un Dockerfile dentro del proyecto Rails, en este caso dentro de la carpeta blog que
corresponde al proyecto Rails.

**Obs.:** Cuidado con el comando COPY . ., que copia todo el directorio desde donde se se ejecuta docker build. 
Si se ejecuta en el home se estarían copiando muchas cosas innecesarias (menos mal tira un error de permisos cuando 
se ejecuta desde el home), esto se puede evitar con un .dockerignore, o creando el Dockerfile dentro de una carpeta vacía.
En este caso el Dockerfile debe ubicarse dentro del proyecto blog en el host local, porque justamente se quiere ejecutar
este proyecto dentro del contenedor y debe copiarse todo el proyecto dentro del contenedor.

```Dockerfile
# Crea la imagen en base a una imagen pre-existente  
FROM corgibytes/ruby-1.9.3

# nodejs es un requerimiento para poder ejecutar la aplicación Rails
# Lo siguiente no me funcionó, igual no es neceario para un API
# RUN apt-get update -qq && apt-get install -y nodejs

# Indica cual es el directorio de trabajo dentro del contenedor  
WORKDIR /app 

# Copia al directorio actual dentro del directorio de trabajo del contenedor
# Obs.: Para que se copie en /app, es importante haberlo definido antes como directorio de trabajo, osino se copiará dentro de la raiz del contenedor. También se puede indicar explícitamente donde se quiere copiar con COPY . /app
COPY . .  
  
# Ejecuta el comando bundle para instalar las gemas  
RUN bundle
```

Generar la imagen
```sh
docker build -t railsapp .
```

Ejecutar la aplicación Rails
```sh
docker run -p 3001:3000 railsapp rails s -b 0.0.0.0
```
- `-p`: Realiza un mapeo de puertos para acceder al puerto 3000 del contenedor a través del puerto 3001 del host
(máquina local). También se puede dejar como 3000:3000.
- `-b 0.0.0.0`: Permite que la aplicación se pueda acceder desde cualquier dirección ya que por defecto solo es accesible
desde el localhost del contenedor.

**Obs.:** Si la ejecución tira algún error relativo a execjs, se puede evitar el error comentado las gemas
**coffee-rails** y **uglifier** del Gemfile. Este error podría deberse a la ausencia de nodejs dentro del contenedor, 
pero no pude solucionarlo ni ejecutando apt-get install nodejs, se queda colgado la ejecución de la instalación de node
desde el contenedor y desde el Dockerfile.

Una vez solucionados todos los problemas se accede a localhost:3001 para ver la aplicación funcionando.

Esta versión fue muy tediosa y a duras penas logré hacerla funcionar. Como ya tengo un Gemfile y un Gemfile.lock que en
su momento funcionarion y que justamente no tienen las gemas problematicas, fue mejor proceder con ese Gemfile para evitar
otros posibles problemas no detectados todavía.

#### 2. Nuevo proyecto Rails desde Gemfile y Gemfile.lock existentes
Crear una carpeta llamada ecom en el home, y copiar dentro de ecom el Gemfile y Gemfile.lock a reutilizar.

Desplegar un contenedor para trabajar desde el home
```sh
docker run -it --rm -v ${PWD}:/app corgibytes/ruby-1.9.3 bash
```

Una vez dentro del contenedor, crear el proyecto
```sh
cd /app/ecom   # Acceder a la carpeta destino del proyecto Rails
bundle install # Instalar gemas
cd ..          # Volver a la carpeta base del home
rails new ecom --database=postgresql # Crear el proyecto. Cuando muestre el mensaje de conflicto en Gemfile, tipear n para que no sobreescriba el Gemfile existente
chmod -R 777 ecom # Actualizar recursivamente los permisos para que cualquiera pueda realizar cambios
cd ecom
rails s # Esto va a fallar y es lo esperado porque todavía no se configuró la conexión con postgres
exit # Salir del contenedor
```

Crear un Dockerfile dentro del proyecto ecom con lo siguiente
````Dockerfile
# Crea la imagen en base a una imagen pre-existente  
FROM corgibytes/ruby-1.9.3

# Indica cual es el directorio de trabajo dentro del contenedor  
WORKDIR /app 

# Copia al directorio actual dentro del directorio de trabajo del contenedor
COPY . .  
  
# Ejecuta el comando bundle para instalar las gemas  
RUN bundle
````

Construir la imagen y desplegar el contenedor
````sh
docker build -t ecom .
docker run --rm -p 3000:3000 ecom rails s -b 0.0.0.0
````
Al momento de desplegar el contenedor se lanza un error relativo a postgres, esto es lo esperado, ahora hay que
configurar un contenedor postgres y conectar con el mismo.

#### Conectar contenedores
Borrar todas los contenedores e imagenes existentes.

Actualizar database.yml indicando "postgres" sin las comillas en host, username y password de los entornos development, test, production.

Crear una red para que el docker de rails y de postgres puedan comunicarse
````sh
docker network create rails_postgres
````

Ejecutar postgres
````sh
docker run --network rails_postgres --name postgres -d -e POSTGRES_PASSWORD=postgres postgres:9.6
````
el --name indicado es postgres y a este host se conectará la aplicación según lo indicado en database.yml. 
Si el name acá fuera bd, en el database.yml se pondría host: db en vez de host: postgres.

Volver a generar la imagen de la app
````sh
docker build -t ecom .
````

Generar la base de datos (Esto es neceario para que al momento de iniciar Rails no falle porque la bd no existe)
````sh
docker run --rm --network rails_postgres --name rails_3 -p 3000:3000 ecom rake db:create
````
el --name no es realmente necesario aqui
En realidad tira un error por no poder crear la base de datos de test, esto es por que para crear la bd de tests
requiere un permiso de superusuario, pero por ahora esto basta. Igual se podría intentar acceder al contenedor y actualizar
los permisos, debería funcionar aunque no lo probé.

**Obs.:** El problema del error al crear la base de datos de test es porque el host para test no estaba correctamente en database.yml

Ejecutar la app
````sh
docker run --rm --network rails_postgres --name rails_3 -p 3000:3000 ecom rails s -b 0.0.0.0
````

#### Conectar contenedores a través de docker-compose
Crear dentro del proyecto Rails, un archivo docker-compose.yml con el siguiente contenido
````yml
services:  
  postgres:  
    image: postgres:9.6  
    volumes:  
      # Named volume to persist database data outside of container.  
      # Format is "named_volume:path/in/container"      
      - db_pg_data:/var/lib/postgresql/data  
  
      # Host mount for one-time initialization.  
      # Format is "./path/on/host:/path/in/container"      
      # - ./init.sql:/docker-entrypoint-initdb.d/init.sql  
    ports:  
      # Map to something other than default 5432 on host in case Postgres  
      # is also running natively on host.      
      # Format is "host:container"      
      - "5434:5432"  
    # env_file: .env  
    environment:  
        # Sets the superuser password for PostgreSQL  
        POSTGRES_PASSWORD: postgres
    networks:
        - network1 # Referencia al network1 definido más abajo  

networks:
    network1:
        name: rails_postgres # Se usa el network creado anteriormente
        external: true

volumes:  
  db_pg_data:
````

Detener y borrar el contenedor de base de datos que se está ejecutando
````sh
docker stop postgres # Detener el contenedor de base datos
docker rm postgres # Borrar el contenedor
docker rmi postgres:9.6 # Borrar la imágen
````

Construir la imagen
````sh
docker-compose up  # Construir la imagen
docker-compose ps -a # Comprobar que el contenedor se esté ejecutando
````

Ejecutar la aplicación
````sh
docker run --rm --network rails_postgres --name rails_3 -p 3000:3000 ecom rake db:create # Esto tirará un error respecto a la bd de test, pero no importa por ahora
docker run --rm --network rails_postgres --name rails_3 -p 3000:3000 ecom rails s -b 0.0.0.0
````

#### Arreglar error al iniciar la base de datos
Ahora se va a arreglar el error lanzado al momento de crear la bd de test, agregando un archivo init.sql con el siguiente contenido
````sql
create role ecom with CREATEDB SUPERUSER login password 'ecom';
````
El role creado con el parámetro superuser permitirá crear la bd de test, ya que Rails necesita ciertos permisos por lo 
invasivo que es la generación de la base de datos de test.

Se actualiza database.yml indicando "ecom" sin las comillas en username y password para los entornos development, test y production.

Se actualiza docker-compose.yml descomentando la línea:
````yml
- ./init.sql:/docker-entrypoint-initdb.d/init.sql
````

Se debe borrar todo y volver a regenerar
````sh
docker-compose down # Apagar el contenedor y borrarlo
docker volume rm ecom_db_pg_data # Borrar el volumen de persistencia
docker rmi ecom # Borrar la imagen
docker build -t ecom . # Regenerar la imagen para que tome los cambios en database.yml
docker-compose up # Levantar el contenedor de base de datos
````

Ejecutar la aplicación
````sh
docker run --rm --network rails_postgres --name rails_3 -p 3000:3000 ecom rake db:create
docker run --rm --network rails_postgres --name rails_3 -p 3000:3000 ecom rails s -b 0.0.0.0
````

Igual se lanza un error respecto a test, creo que es un problema con el RAILS_ENV, al final parece que no era problema
de permisos de usuario. Aunque igual, al cambiar los nombres de usuario y contraseña en database.yml, el archivo init.sql
ya no es necesario

#### Agregar el servicio para la aplicación
Actualizar docker-compose.yml agregando el servicio para rails y quitando las secciones de network porque los servicios
de docker-compose se ejecutan por defecto en una misma red y no hace falta esa configuración extra.
````yml
services:  
  postgres:  
    image: postgres:9.6  
    volumes:  
      # Named volume to persist database data outside of container.  
      # Format is "named_volume:path/in/container"      
      - db_pg_data:/var/lib/postgresql/data  
  
      # Host mount for one-time initialization.  
      # Format is "./path/on/host:/path/in/container"      
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql  
    ports:  
      # Map to something other than default 5432 on host in case Postgres  
      # is also running natively on host.      
      # Format is "host:container"      
      - "5434:5432"  
    env_file: .env  
    environment:  
        # Sets the superuser password for PostgreSQL  
        POSTGRES_PASSWORD: postgres
  rails:
    build: . # Construye en base al Dockerfile encontrado en el directorio donde se ejecuta docker-compose up
    volumes:
      # Named volume to persist database data outside of container.
      # Format is "named_volume:path/in/container"
      - .:/app
    # env_file: .env
    # environment: # Define variables de entorno que serán utilizados dentro de la aplicación Rails
      # - DATABASE_NAME=${DATABASE_NAME}
      # - DATABASE_USER=${DATABASE_USER}
      # - DATABASE_PASSWORD=${DATABASE_PASSWORD}
      # - DATABASE_PORT=5432
      # - DATABASE_HOST=database
    ports:
      # Map to something other than default 5432 on host in case Postgres
      # is also running natively on host.
      # Format is "host:container"
      - "3000:3000"
    depends_on:
      - postgres # Referencia al servicio postgres definido mas arriba, esto indica que se va a crear el servicio rails luego del servicio postgres, aunque esto no asegura que postgres ya esté listo para ser usado por rails.  	
volumes:  
  db_pg_data:
````

Agregar al final del Dockerfile
````Dockerfile
CMD ["rails", "s", "-b", "0.0.0.0"]
````

Reiniciar todo y volver a levantar
````sh
docker compose down
docker volume rm ecom_db_pg_data
docker rmi ecom # Borrar la imagen del proyecto para que tome los cambios del Dockerfile
docker-compose up
````

Se construye todo pero falla ya que rails trata de conectarse a postgres antes de que postrgres termine su parte, par
a solucionar esto se va a agregar un archivo entrypoint.sh
````sh
#!/bin/bash  
set -e  
  
if [ -f tmp/pids/server.pid ]; then  
  rm tmp/pids/server.pid  
fi  
  
# Función para esperar que la base de datos esté disponible  
# Esta función fue proveída por ChatGPT  
function wait_for_db() {  
  echo "Waiting for database to be ready..."  
  until nc -z -v -w30 $DB_HOST $DB_PORT; do  
    echo "Waiting for database connection at $DB_HOST:$DB_PORT..."  
    sleep 1  
  done  
  echo "Database is ready!"  
}  
  
# Definir variables de entorno para host y puerto de la base de datos (modifica si usas otro tipo de DB)  
DB_HOST=${DB_HOST:-ecom-postgres-1.ecom_default} # ecom-postgres-1.ecom_default es el nombre del servicio en docker-compose  
DB_PORT=${DB_PORT:-5432}  
  
# Esperar a que la base de datos esté disponible  
wait_for_db  
  
# La función wait_for_db evite que rake db:setup intente acceder a la base de datos  
# antes de que postgres esté listo  
bundle exec rake db:setup  
  
bundle exec rails s -b 0.0.0.0  
# El comando para iniciar rails se puede agregar aquí, en el Dockerfile con CMD o en el  
# docker-compose a través de command, conviene que se especifique rails s en un sólo lugar  
# para no causar confusión o algún error
````

Actualizar el Dockerfile quedando así
````Dockerfile
# Crea la imagen en base a una imagen pre-existente  
FROM corgibytes/ruby-1.9.3 
  
# Las siguientes líneas son necesarias para actualizar debian e instalar netcat.  
# En un entorno de producción no es recomendable usar trusted=yes  
RUN rm /etc/apt/sources.list  
RUN echo "deb [trusted=yes] http://archive.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list.d/jessie.list  
RUN echo "deb [trusted=yes] http://archive.debian.org/debian jessie main" >> /etc/apt/sources.list.d/jessie.list  
  
# Necesario para la funcion wait_for_db del entrypoint que usa el comando nc de netcat  
RUN apt-get update && apt-get install -y netcat-traditional  
  
# Indica cual es el directorio de trabajo dentro del contenedor  
WORKDIR /app  
  
# Copia al directorio actual dentro del directorio de trabajo del contenedor  
COPY . .  
  
# Ejecuta el comando bundle para instalar las gemas  
RUN bundle  
  
# El contenedor ejecuta la aplicación  
# CMD ["rails", "s", "-b", "0.0.0.0"]  
  
COPY entrypoint.sh /usr/bin/  
RUN chmod +x /usr/bin/entrypoint.sh  
ENTRYPOINT ["entrypoint.sh"]
````

También se debe actualizar el host a ecom-postgres-1 en database.yml? No creo, capaz me confundí pero ya no quiero ponerme a probar.

Reiniciar todo y volver a levantar
````sh
docker compose down
docker volume rm ecom_db_pg_data
docker rmi ecom-rails # Borrar la imagen del proyecto para que tome los cambios del Dockerfile
docker-compose up
````

Acceder al contenedor de rails
````sh
docker-compose exec rails bash
````

Ahora lo que se va a actualizar database.yml para reutilizar propiedades de bases de datos. También se pasarán variables
de entorno en el docker-compose y en database.yml. Es importante tener instalado dotenv-rails para poder leer las variables
de entorno desde database.yml.

Los archivos quedan así
.env
````
POSTGRES_PASSWORD=postgres  
DATABASE_NAME=ecom_development  
DATABASE_USER=ecom  
DATABASE_PASSWORD=ecom  
DATABASE_PORT=5432  
DATABASE_HOST=localhost
````

.docker-compose.yml
````yml
# From:  
# - https://danielabaron.me/blog/rails-postgres-docker/  
# - https://www.digitalocean.com/community/tutorials/containerizing-a-ruby-on-rails-application-for-development-with-docker-compose-es  
# - https://medium.com/@luismiguel.cabezas/docker-para-programadores-rails-parte-1-51b7313cba36  
# - https://medium.com/@luismiguel.cabezas/docker-para-programadores-rails-parte-2-2686d12f23ef  
# - https://medium.com/simform-engineering/dockerize-your-rails-7-app-3223cc851129  
services:  
  postgres:  
    image: postgres:9.6  
    volumes:  
      # Named volume to persist database data outside of container.  
      # Format is "named_volume:path/in/container"      
      - db_pg_data:/var/lib/postgresql/data  
      # Host mount for one-time initialization.  
      # Format is "./path/on/host:/path/in/container"      
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql  
    ports:  
      # Map to something other than default 5432 on host in case Postgres  
      # is also running natively on host.      # Format is "host:container"      
      - "5434:5432"  
    env_file: .env  
    environment:  
      # Sets the superuser password for PostgreSQL  
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}  
  
  rails:  
    build: . # Construye en base al Dockerfile encontrado en el directorio donde se ejecuta docker-compose up  
    volumes:  
      # Named volume to persist database data outside of container.  
      # Format is "named_volume:path/in/container"      - .:/app  
    env_file: .env  
    environment: # Define variables de entorno que serán utilizados dentro de la aplicación Rails  
      - DATABASE_NAME=${DATABASE_NAME}  
      - DATABASE_USER=${DATABASE_USER}  
      - DATABASE_PASSWORD=${DATABASE_PASSWORD}  
      - DATABASE_PORT=5432  
      - DATABASE_HOST=postgres # Notar que el host es postgres en referencia al servicio definido aquí  
                               # Si se decea ejecutar la aplicacion directamente en el host y no en un contanedor el host                               # debe ser localhost, aunque esto es un depende.    ports:  
      # Map to something other than default 5432 on host in case Postgres  
      # is also running natively on host.      # Format is "host:container"      - "3000:3000"  
    depends_on:  
      - postgres  # Referencia al servicio postgres definido mas arriba, esto indica que se va a crear el servicio rails  
                  # luego del servicio postgres, aunque esto no asegura que postgres ya esté listo para ser usado por rails.  
volumes:  
  db_pg_data:
````

database.yml
````yml
# PostgreSQL. Versions 8.2 and up are supported.  
#  
# Install the pg driver:  
#   gem install pg  
# On Mac OS X with macports:  
#   gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config  
# On Windows:  
#   gem install pg  
#       Choose the win32 build.  
#       Install PostgreSQL and put its /bin directory on your path.  
#  
# Configure Using Gemfile  
# gem 'pg'  
#  
default: &default  
  adapter: postgresql  
  encoding: unicode  
  username: <%= ENV['DATABASE_USER'] %>  
  password: <%= ENV['DATABASE_PASSWORD'] %>  
  host: <%= ENV['DATABASE_HOST'] %>  
  port: <%= ENV['DATABASE_PORT'] %>  
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>  
  
development:  
  <<: *default  
  database: <%= ENV['DATABASE_NAME'] %>  
  
  # Connect on a TCP socket. Omitted by default since the client uses a  
  # domain socket that doesn't need configuration. Windows does not have  # domain sockets, so uncomment these lines.  #host: localhost  #port: 5432  
  # Schema search path. The server defaults to $user,public  #schema_search_path: myapp,sharedapp,public  
  # Minimum log levels, in increasing order:  #   debug5, debug4, debug3, debug2, debug1,  #   log, notice, warning, error, fatal, and panic  # The server defaults to notice.  #min_messages: warning  
# Warning: The database defined as "test" will be erased and  
# re-generated from your development database when you run "rake".  
# Do not set this db to the same as development or production.  
test:  
  <<: *default  
  database: ecom_test  
  
production:  
  <<: *default  
  database: ecom_production
````

# Bibliografía
- [Setup a Rails Project with Postgres and Docker · Daniela Baron](https://danielabaron.me/blog/rails-postgres-docker/)
- [Cómo disponer en contenedor una aplicación de Ruby on Rails para el desarrollo con Docker Compose | DigitalOcean](https://www.digitalocean.com/community/tutorials/containerizing-a-ruby-on-rails-application-for-development-with-docker-compose-es)
- [Docker para programadores Rails (parte 1) | by Luis Miguel Cabezas Granado | Medium](https://medium.com/@luismiguel.cabezas/docker-para-programadores-rails-parte-1-51b7313cba36)
- [Docker para programadores Rails (parte 2) | by Luis Miguel Cabezas Granado | Medium](https://medium.com/@luismiguel.cabezas/docker-para-programadores-rails-parte-2-2686d12f23ef)
- [Dockerize your rails 7 app.. Discover the usage of Docker within a… | by Hardik Vekariya | Simform Engineering | Medium](https://medium.com/simform-engineering/dockerize-your-rails-7-app-3223cc851129)
- [Uso de Docker para desarrolladores (Parte 1 – Conceptos y primeros pasos)](https://www.fernandoaparicio.net/uso-de-docker-para-desarrolladores-parte-1-conceptos-y-primeros-pasos/)
