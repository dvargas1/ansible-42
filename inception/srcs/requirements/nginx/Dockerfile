FROM alpine:3.19

RUN apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx
COPY ./conf/nginx.conf /etc/nginx/

RUN mkdir -p /etc/ssl/private
COPY ./conf/nginx.crt /etc/ssl/certs/certificate.crt
COPY ./conf/nginx.key /etc/ssl/private/certificate.key

ENTRYPOINT ["nginx"]
