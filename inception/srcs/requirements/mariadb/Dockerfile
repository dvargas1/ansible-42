FROM alpine:3.19

RUN apk add --no-cache mariadb mariadb-client

RUN mariadb-install-db --user=mysql --basedir=/usr --datadir=/database

COPY ./tools/setup.sh /
COPY ./conf/mariadb-server.cnf /etc/my.cnf.d/

RUN chmod +x /setup.sh
ENTRYPOINT ["/setup.sh"]
