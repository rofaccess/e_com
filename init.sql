create role e_com with CREATEDB SUPERUSER login password 'e_com';
-- Se pueden crear las bases de datos en este punto pero se ve mejor hacerlo con rake db:setup en el entrypoint
-- CREATE DATABASE e_com_development;
-- GRANT ALL PRIVILEGES ON DATABASE e_com_development TO e_com;
