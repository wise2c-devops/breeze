#!/bin/bash
set -e
# Check if there are no cert files under /etc/kubernetes/pki
if [ "`ls -A /etc/kubernetes/pki/`" != "" ]; then
  exit 1
fi

# K8S CA

cd /var/lib/wise2c/tmp/kubernetes/

cfssl gencert -initca ca-csr.json | cfssljson -bare /var/lib/wise2c/tmp/kubernetes/ca

# K8S apiserver-kubelet-client certificate
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubelet-csr.json | cfssljson -bare apiserver-kubelet-client

# K8S  front-proxy certificate
cfssl gencert -initca front-proxy-ca-csr.json | cfssljson -bare front-proxy-ca
cfssl gencert -ca=front-proxy-ca.pem -ca-key=front-proxy-ca-key.pem -config=ca-config.json -profile=kubernetes front-proxy-client-csr.json | cfssljson -bare front-proxy-client

# K8S Service Account Key
openssl genrsa -out sa.key 2048
openssl rsa -in sa.key -pubout -out sa.pub

#生成admin证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin

#生成controller-manager证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes controller-manager-csr.json | cfssljson -bare controller-manager

#生成scheduler证书
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes scheduler-csr.json | cfssljson -bare scheduler

cd /var/lib/wise2c/tmp/kubernetes/
mv ca.pem /etc/kubernetes/pki/ca.crt
mv ca-key.pem /etc/kubernetes/pki/ca.key
mv apiserver-kubelet-client.pem /etc/kubernetes/pki/apiserver-kubelet-client.crt
mv apiserver-kubelet-client-key.pem /etc/kubernetes/pki/apiserver-kubelet-client.key
mv front-proxy-ca.pem /etc/kubernetes/pki/front-proxy-ca.crt
mv front-proxy-ca-key.pem /etc/kubernetes/pki/front-proxy-ca.key
mv front-proxy-client.pem /etc/kubernetes/pki/front-proxy-client.crt
mv front-proxy-client-key.pem /etc/kubernetes/pki/front-proxy-client.key
mv sa.pub /etc/kubernetes/pki/sa.pub
mv sa.key /etc/kubernetes/pki/sa.key

mv *.pem /etc/kubernetes/pki/
