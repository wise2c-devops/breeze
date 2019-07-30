#!/bin/bash
set -e

# Check if there are no cert files under /etc/kubernetes/pki/etcd/
if [ "`ls -A /etc/etcd/pki`" != "" ]; then
  exit 1
fi


# ETCD CA
cd /var/tmp/wise2c/etcd/

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# ETCD certificate
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=127.0.0.1,{% for host in play_hosts %}{{ host }}{% if not loop.last %},{% endif %}{% endfor %} -profile=etcd etcd-csr.json | cfssljson -bare etcd

cd /var/tmp/wise2c/etcd/
cp *.pem /etc/etcd/pki/


