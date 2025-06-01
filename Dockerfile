FROM alpine:latest

RUN apk add --update --no-cache bash openssl

WORKDIR /certs
COPY ./*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

CMD ["/usr/local/bin/generate-certs.sh"]
