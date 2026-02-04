FROM alpine:3.19

RUN apk add --no-cache \
    php82 \
    php82-session \
    php82-mysqli \
    php82-mbstring \
    php82-openssl \
    php82-curl \
    php82-zip \
    php82-bz2 \
    php82-gd \
    php82-xml \
    php82-simplexml \
    php82-tokenizer \
    php82-ctype \
    php82-iconv

RUN mkdir -p /var/www/phpmyadmin && \
    wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz && \
    tar xzf phpMyAdmin-5.2.1-all-languages.tar.gz --strip-components=1 -C /var/www/phpmyadmin && \
    rm phpMyAdmin-5.2.1-all-languages.tar.gz

COPY ./conf/config.inc.php /var/www/phpmyadmin/
COPY ./tools/setup.sh /

RUN chmod +x /setup.sh
ENTRYPOINT ["/setup.sh"]
