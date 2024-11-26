# Docker
## Comandos básicos
Descargar imagen Ruby
> docker pull corgibytes/ruby-1.9.3

Ver imágenes existentes
> docker images

Ejecutar comando Ruby
> docker run corgibytes/ruby-1.9.3 ruby -e "puts 'Hola Mundo'"

- `-e`: es un argumento que se le pasa al comando ruby del contenedor, el cual permite ejecutar código directamente
desde la línea de comandos.

Por cada ejecución del comando anterior, se creará un nuevo contenedor

Ver contenedores
> docker ps -a

Evitar que se creen contenedores por cada ejecución
> docker run --rm corgibytes/ruby-1.9.3 ruby -e "puts 'Hola Mundo'"

- `--rm`: Elimina automáticamente el contenedor después de que se detiene.

Eliminar un contenedor
> docker rm <CONTAINER_ID> <CONTAINER_ID> ... # or <CONTAINER_NAME>

Eliminar todos los contenedores
> docker container prune

Detener todos los contenedores en ejecución y luego eliminarlos
````sh
docker stop $(docker ps -q)
docker rm $(docker ps -a -q) # or docker container prune
````
- `-q`: Lista los ids de los contenedores en ejecución sin mostrar más detalles.
- `-a`: Lista los contenedores sin importar su estado, ya sea que estén en ejecución, detenidos o hayan fallado.

Eliminar una imagen
> docker rmi <IMAGE_ID>

Eliminar todas las imagenes
> docker rmi $(docker images -q)

# Comandos útiles
## 1. docker run
Crea e inicia un contenedor basado en una imagen.

Se utiliza para crear y ejecutar un nuevo contenedor desde cero.

**Sintaxis:**
> docker run [opciones] imagen comando

**Ejemplo:**
> docker run ubuntu echo "Hola Mundo"

Esto descarga (si no existe localmente) la imagen ubuntu, crea un contenedor, ejecuta el comando echo "Hola Mundo", y luego detiene el contenedor.

**Opciones comunes:**
- `-it`: Ejecuta el contenedor en modo interactivo con una terminal.
- `--rm`: Elimina automáticamente el contenedor después de que se detiene.
- `-d`: Ejecuta el contenedor en segundo plano (modo "detached").
- `-p`: Mapea puertos entre el host y el contenedor.

## 2. docker exec
Ejecuta un comando dentro de un contenedor que ya está en ejecución.

Para interactuar con un contenedor en curso sin reiniciarlo. Para ejecutar comandos adicionales en un contenedor ya
iniciado, como depuración o configuración.

**Sintaxis:**
> docker exec [opciones] contenedor comando

**Ejemplo:**
> docker exec -it nombre_contenedor bash

Esto abre una sesión interactiva dentro del contenedor nombre_contenedor.

**Opciones comunes:**
- `-it`: Modo interactivo con acceso a una terminal.

## 3. docker start
Inicia un contenedor que ya existe (pero está detenido).

Para reanudar un contenedor previamente creado. Para reiniciar un contenedor sin crear uno nuevo.

**Sintaxis:**
> docker start [opciones] contenedor

**Ejemplo:**
> docker start -i nombre_contenedor

Esto inicia el contenedor nombre_contenedor y lo adjunta a la terminal en modo interactivo.

## 4. docker stop
Detiene un contenedor en ejecución de forma ordenada.

Para apagar un contenedor sin eliminarlo. Para detener contenedores sin perder su estado.

**Sintaxis:**
> docker stop contenedor

**Ejemplo:**
> docker stop nombre_contenedor
    

## 5. docker restart
Reinicia un contenedor (lo detiene y lo inicia nuevamente).

Para reiniciar un contenedor rápidamente. Cuando necesitas reiniciar un contenedor para aplicar cambios o solucionar
problemas.

**Sintaxis:**
> docker restart contenedor

**Ejemplo:**
> docker restart nombre_contenedor    

## 6. docker attach
Adjunta tu terminal al proceso principal de un contenedor en ejecución.

Para ver la salida en tiempo real de un contenedor o interactuar con él. Para monitorear o interactuar con un contenedor
en ejecución.

**Sintaxis:**
> docker attach contenedor

**Ejemplo:**
> docker attach nombre_contenedor
    
**Comparativa rápida:**

| Comando        | Propósito                                       | Estado del contenedor           |
| -------------- | ----------------------------------------------- | ------------------------------- |
| docker run     | Crear y ejecutar un contenedor nuevo            | Nuevo contenedor                |
| docker exec    | Ejecutar comandos en un contenedor en ejecución | Contenedor ya en ejecución      |
| docker start   | Iniciar un contenedor detenido                  | Contenedor existente y detenido |
| docker stop    | Detener un contenedor en ejecución              | Contenedor en ejecución         |
| docker restart | Reiniciar un contenedor                         | Detenido o en ejecución         |
| docker attach  | Conectar la terminal al proceso principal       | Contenedor en ejecución         |

## Contenedor Rails
A continuación se describen los pasos para instalar Rails dentro de un contenedor e inicializar un nuevo proyecto
Rails en el host local.

Crear y ejecutar un nuevo contenedor de la imágen corgibytes/ruby-1.9.3 ejecutando el comando bash
> docker run -it --rm -v ${PWD}:/usr/src/app corgibytes/ruby-1.9.3 bash

- `--rm`: indica que no se guardará una copia del contenedor, por lo que se eliminará luego de usarlo.
- `-it`: indica una interacción con el contenedor para enviarle comandos, básicamente permite ingresar dentro del
contenedor y poder ejecutar comandos.
- `-v`: crea un vinculo entre el directorio donde se está ejecutando el comando y un directorio dentro del
contenedor (/usr/src/app), todo lo que se guarde dentro del directorio indicado aparecerá en el directorio local. A esto
se le llama volumen v.

Una vez dentro del contenedor, se proece a instalar Rails.

Ingresar a la carpeta de trabajo
> cd /usr/src/app

Instalar Rails
> gem install rails -v 3.2.22.5

El intento previo requiere instalar otras gemas manualmente o posiblemente instalar una versión específica de bundle 
y/o RubyGems. Para ahorrar tiempo es mejor usar un Gemfile y Gemfile.lock si es que se tiene.

Copiar Gemfile y Gemfile.lock al contenedor (Ubicarse donde estan los archivos a copiar o usar ruta relativa). Primero 
se requiere cambiar los permisos para poder modificar localmente.
> docker cp Gemfile <CONTAINER_ID>:/usr/src/app
> docker cp Gemfile.lock <CONTAINER_ID>:/usr/src/app

Cambiar permisos para poder modificar el proyecto de forma local (Esto asume que se tiene un proyecto llamado railsapp)
> sudo chmod -R 747 railsapp

Crear un Dockerfile dentro del proyecto local
````Dockerfile
# Crea la imagen en base a una imagen pre-existente  
FROM corgibytes/ruby-1.9.3:1.0.0  
  
# Copia al directorio actual a un directorio dentro del contenedor  
COPY . /usr/src/app/  
  
# Indica cual es el directorio de trabajo dentro del contenedor  
WORKDIR /usr/src/app  
  
# Ejecuta el comando bundle para instalar las gemas  
RUN bundle
````

Construir la imagen
> docker build .
> ### Alternativa
> docker build -t <TAG_NAME> .

Verificar que la imagen se haya creado
> docker images

Es convienente indicar un nombre para la imagen creada para que sea más fácil de identificar
> docker tag <CONTAINER_ID> railsapp

Ejecutar la aplicación
> docker run -p 3001:3000 railsapp rails s -b 0.0.0.0

- `-p`: Realiza un mapeo de puertos para acceder al puerto 3000 del contenedor a través del puerto 3001 del host
(máquina local). 
- `-b 0.0.0.0`: para que la aplicación se pueda acceder desde cualquier dirección ya que por defecto solo es accesible 
desde el localhost del contenedor.

El comando para ejecutar rails se puede añadir al Dockerfile de la siguiente manera
````Dockerfile
...
CMD ["rails", "s", "-b", "0.0.0.0"]
````

Se vuelve a generar la image, esta vez versionando
> docker build -t railsapp -t railsapp:1.1 .

Se ejecuta la aplicación (o el contenedor)
> docker run -p 3001:3000 railsapp:1.1

# Docker Compose
Es una herramienta de Docker para gestionar múltiples contenedores

Crear el archivo docker-compose.yml en la raiz del proyecto.
```` yaml
services:      
  web:  # Nombre de la imagen y contenedor
    build: .  # Para que utilice el archivo Dockerfile desde donde se ejecuta docker
    ports:  # Mapeo de puertos
      - "3001:3000"
````

Ejecutar el compose
> docker-compose up

**Obs.:** En veriones más recientes de docker el archivo puede llamarse compose.yaml y el comando para ejecutar es
simplemente
> docker compose

Al ejecutar el comando se genera una imagen por cada servicio que contenga la directiva build, se crea y lanza un 
contenedor por cada servicio. Tener en cuenta que la imagen y el contenedor se crean una sola vez, luego se vuelve a 
reutilizar el contenedor, no es que se crean varios contenedores como docker run o que se borren los contenedores como 
cuando se usa el parámetro --rm. Según mis pruebas, a partir de la segunda ejecución, sólo se ejecuta el comando CMD 
del Dockerfile. Osea que en la primera ejecución se guarda cierta información en la imagen, ya que ni siquiera se vuelve
a ejecutar el bundle en la segunda ejecución. Si se borra la imagen y se vuelve a crear de nuevo, entonces si se ejecuta
el bundle.

Ingresar dentro del contenedor (El contenedor debe estar en ejecución)
> docker exec -it <CONTAINER_ID> /bin/bash

Crear un scaffold dentro del contenedor
> rails generate scaffold Post title:string body:text

Cualquier cambio realizado queda solo en el contenedor, por lo que si se borra ya se pierde esa información. 
Para sincronizar los cambios con el proyecto local se usan un volumen local. Un volumen local es un sistema de ficheros 
compartido entre la máquina local y el contenedor (algo parecido a utilizar -v en docker). Cada servicio puede tener su 
configuración de volúmenes. Gracias a los volumenes se pueden modificar los archivos en local y que tengan efecto en el 
contenedor.

Agregar un volumen a docker-compose.yml
````yaml
services:      
  web:  # Nombre de la imagen y contenedor
    build: .  # Para que utilice el archivo Dockerfile desde dond se ejecuta docker
    ports:  # Mapeo de puertos
      - "3001:3000"
    volumes:
      - .:/usr/src/app
````

Parar la ejecución de docker compose y volver a ejecutarlo, esto detectará los cambios en el archivo de configuración
````bash
docker-compose down
docker-compose up -d
````

- `-d`: es para lanzar el servicio en segundo plano

Crear un scaffold dentro del contenedor sin ingresar al contenedor
````bash
docker exec -it railsapp-web-1 rails generate scaffold Post title:string body:text
docker exec -it railsapp-web-1 rake db:migrate
````

Lo anterior realizará cambios en el proyecto local.

Comandos útiles
````bash
docker-compose ps # Muestra contenedores asociados con sus estados
docker-compose stop # Parar todos los servicios
docker-compose stop [service-name] # Parar un servicio especifico
docker compose build [service-name] # Reconstruye la imagen del servicio especificado
docker compose start [service-name] # Inicia el servicio especificado
````

# Contenedor Redis

Agregar el servicio redis al docker-compose.yml
````yaml
services:      
  web:  # Nombre de la imagen y contenedor
    build: .  # Para que utilice el archivo Dockerfile desde dond se ejecuta docker
    ports:  # Mapeo de puertos
      - "3001:3000"
    volumes:
      - .:/usr/src/app
  redis:
    image: redis
````

Acceder a la consola de redis y comprobar su funcionamiento
````bash
docker-compose run redis redis-cli -h redis
ping
SET numero 23
GET numero 23
````

Crear un controlador
> docker-compose exec web rails g controller prueba index

Actualizar los archivos generados para conectarse a Redis
````ruby
class PruebaController < ApplicationController  
  def index  
    redis = Redis.new(host: "redis", port: 6379)  
    @numero = redis.get "numero"  
  end
end

# Vista
<h1>Número obtenido desde REDIS: <%= @numero %></h1>
````
Acceder a http://localhost:3001/prueba/index y ser verá el número seteado antes.

# Entrypoint
El entrypoint se encarga de ejeuctar comandos al levantar el contenedor de la imagen y no durante el momento de
construcción de la imagen, en este archivo se puede ejecutar el comando rake db:migrate

```sh
#!/bin/bash

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

RAILS_ENV=$RAILS_ENV bundle exec rails db:migrate

RAILS_ENV=$RAILS_ENV bundle exec rails s -b 0.0.0.0
```

Luego reemplazar el comando CMD en el Dockerfile
```Dockerfile
...
# Alternativa directa al entrypoint  
# CMD ["rails", "s", "-b", "0.0.0.0"]  
  
COPY entrypoint.sh /usr/bin/  
RUN chmod +x /usr/bin/entrypoint.sh  
ENTRYPOINT ["entrypoint.sh"]
```

También se puede ejecutar db:setup para crear la base de datos y ejecutar migraciones y seeds.
> docker-compose exec app rake db:setup

# Bibliografía
- [Docker para programadores Rails (parte 1) | by Luis Miguel Cabezas Granado | Medium](https://medium.com/@luismiguel.cabezas/docker-para-programadores-rails-parte-1-51b7313cba36)
- [Docker para programadores Rails (parte 2) | by Luis Miguel Cabezas Granado | Medium](https://medium.com/@luismiguel.cabezas/docker-para-programadores-rails-parte-2-2686d12f23ef)
- [Setup a Rails Project with Postgres and Docker · Daniela Baron](https://danielabaron.me/blog/rails-postgres-docker/)
- [Cómo disponer en contenedor una aplicación de Ruby on Rails para el desarrollo con Docker Compose | DigitalOcean](https://www.digitalocean.com/community/tutorials/containerizing-a-ruby-on-rails-application-for-development-with-docker-compose-es)
- [Dockerize your rails 7 app.. Discover the usage of Docker within a… | by Hardik Vekariya | Simform Engineering | Medium](https://medium.com/simform-engineering/dockerize-your-rails-7-app-3223cc851129)
