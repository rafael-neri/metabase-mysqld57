FROM mysql:5.7

# ENV PATH ${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# ENV MYSQL_ROOT_USER             root
# ENV MYSQL_ALLOW_EMPTY_PASSWORD  true
# ENV MYSQL_ROOT_PASSWORD       root
# ENV MYSQL_CHARSET               utf8mb4
#VOLUME ./init.d:/docker-entrypoint-initdb.d
COPY ./docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY ./conf.d/ /etc/mysql/conf.d/
#RUN chmod 644 /etc/mysql/conf.d/*
#
