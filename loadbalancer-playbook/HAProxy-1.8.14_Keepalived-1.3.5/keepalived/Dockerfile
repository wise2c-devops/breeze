FROM centos:7.5.1804
RUN yum install -y keepalived
COPY keepalived.sh /usr/bin/keepalived.sh
COPY keepalived.conf /etc/keepalived/keepalived.conf
RUN chmod +x /usr/bin/keepalived.sh
ENTRYPOINT ["/usr/bin/keepalived.sh"]
