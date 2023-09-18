FROM mysql:8.0.31

ENV MYSQL_DATABASE sakila

COPY ./scripts-para-contenedor/ /docker-entrypoint-initdb.d/
