#!/bin/sh

mkdir -p /tmp/phpmyadmin
exec php82 -S 0.0.0.0:80 -t /var/www/phpmyadmin
