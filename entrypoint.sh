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
DB_HOST=${DB_HOST:-e_com-postgres-1.e_com_default} # e_com-postgres-1.e_com_default es el nombre del servicio en docker-compose
DB_PORT=${DB_PORT:-5432}

# Esperar a que la base de datos esté disponible
wait_for_db

# La función wait_for_db evite que las siguientes tareas intenten acceder a la base de datos
# antes de que postgres esté listo
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed

# Cuando se tenga el Schema se puede borrar los anteriores y descomentar lo siguiente
# bundle exec rake db:setup

bundle exec rails s -b 0.0.0.0
# El comando para iniciar rails se puede agregar aquí, en el Dockerfile con CMD o en el
# docker-compose a través de command, conviene que se especifique el comando en un sólo lugar
# para no causar confusión o algún error
