FROM alpine:3.19

RUN apk add --no-cache php82 php82-fpm php82-mysqli php82-phar \
    php82-mbstring php82-xml php82-tokenizer php82-ctype php82-iconv && \
    echo "memory_limit = 512M" > /etc/php82/conf.d/memory.ini

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

COPY ./tools/setup.sh /
COPY ./conf/www.conf /etc/php82/php-fpm.d/

RUN chmod +x /setup.sh
ENTRYPOINT ["/setup.sh"]
