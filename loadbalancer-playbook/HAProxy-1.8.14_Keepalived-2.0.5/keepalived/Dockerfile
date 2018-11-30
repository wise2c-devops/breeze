FROM alpine:latest
RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/main" >> /etc/apk/repositories && apk --update -t add keepalived iproute2 grep bash tcpdump sed && rm -f /var/cache/apk/* /tmp/*
COPY keepalived.sh /usr/bin/keepalived.sh
COPY keepalived.conf /etc/keepalived/keepalived.conf
RUN chmod +x /usr/bin/keepalived.sh
ENTRYPOINT ["/usr/bin/keepalived.sh"]
