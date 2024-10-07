#!/bin/bash
# Cualquier cambio en este archivo requiere regenerar la imagen para que se tomen los cambios
# Los comandos para crear la base datos y otros se pueden pasar en el command del docker-compose
# El valor de este archivo recide en que permite borrar el pid, lo cual creo que se puede borrar también con un
# comando de docker-compose, lo otro valorable es la función wait_for_end lo cual es importante la primera vez
# que se inicializa la base de datos, pero una vez iniciado ya podría dejar de ser útil, aunque si hay alguna migración
# podría cobrar de nuevo relevancia si es que se trata de ejecutar la migración antes de que la bd esté lista
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
DB_HOST=${DB_HOST:-e_com-postgres-1.e_com_default} # e_com-postgres-1.e_com_default es el nombre del servicio en docker-compose
DB_PORT=${DB_PORT:-5432}

# Esperar a que la base de datos esté disponible
wait_for_db

# La función wait_for_db evite que las siguientes tareas intenten acceder a la base de datos
# antes de que postgres esté listo
bundle exec rake db:create RAILS_ENV=${RAILS_ENV}
bundle exec rake db:migrate RAILS_ENV=${RAILS_ENV}

if [ "$RAILS_ENV" != "test" ]; then
    bundle exec rake db:seed RAILS_ENV=${RAILS_ENV}
fi


# Cuando se tenga el Schema se puede borrar los anteriores y descomentar lo siguiente
# bundle exec rake db:setup

# Se debe habilitar la siguiente línea para que el Run de Rubymine funcione (No es critico que funcione, pero es cómodo,
# se puede ejecutar simplemente docker-compose up desde la terminal)
# Si se habilita la línea entonces la ejecución termina aquí y e comando exec no se ejecuta por lo que el command
# del docker-compose no se ejecuta, tampoco el CMD.
# bundle exec rails s -b 0.0.0.0
# Si lo anterior se comenta lo siguiente debe estar descomentado para recibir comandos desde docker-compose y para que
# el CMD del Dockerfile también funcione
exec "$@"

# El comando para iniciar rails se puede agregar aquí, en el Dockerfile con CMD o en el
# docker-compose a través de command, conviene que se especifique el comando en un sólo lugar
# para no causar confusión o algún error
