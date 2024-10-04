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
