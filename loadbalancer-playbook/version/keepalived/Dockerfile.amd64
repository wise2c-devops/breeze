FROM centos:7.9.2009
RUN yum install -y keepalived sysvinit-tools nc
COPY keepalived.sh /usr/bin/keepalived.sh
COPY keepalived.conf /etc/keepalived/keepalived.conf
RUN chmod +x /usr/bin/keepalived.sh
ENTRYPOINT ["/usr/bin/keepalived.sh"]
