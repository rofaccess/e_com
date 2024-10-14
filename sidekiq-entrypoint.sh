#!/bin/bash
set -e

# Lo del pid posiblemente no sea necesario, pendiente comprobarlo
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

# Esperar a que la base de datos esté disponible, porque sidekiq requiere conectarse a la base de datos
# Esta función se usa también en entrypoint.sh, pendiente moverlo en otro script para poder reutilizarlo
wait_for_db

bundle exec sidekiq
