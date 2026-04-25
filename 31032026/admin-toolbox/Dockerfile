FROM alpine:latest

RUN apk add --no-cache curl

COPY check.sh /usr/local/bin/check.sh
COPY motd.txt /etc/motd.txt

CMD ["/usr/local/bin/check.sh"]
