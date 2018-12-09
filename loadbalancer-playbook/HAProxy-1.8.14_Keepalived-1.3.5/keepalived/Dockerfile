FROM centos:7.6.1810
RUN yum install -y keepalived sysvinit-tools
COPY keepalived.sh /usr/bin/keepalived.sh
COPY keepalived.conf /etc/keepalived/keepalived.conf
RUN chmod +x /usr/bin/keepalived.sh
ENTRYPOINT ["/usr/bin/keepalived.sh"]
