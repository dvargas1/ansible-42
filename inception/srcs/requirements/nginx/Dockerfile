FROM alpine:3.14

RUN apk add --no-cache nginx
RUN apk add --no-cache openssl

RUN mkdir -p /etc/nginx
COPY ./conf/nginx.conf /etc/nginx/
COPY ./tools/setup.sh  /

RUN mkdir -p /etc/ssl/private
COPY ./conf/nginx.crt /etc/ssl/certs/certificate.crt
COPY ./conf/nginx.key /etc/ssl/private/certificate.key

ENTRYPOINT ["nginx"]
