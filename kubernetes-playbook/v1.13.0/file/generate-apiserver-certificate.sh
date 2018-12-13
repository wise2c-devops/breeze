#!/bin/bash
# Get host IP address and hostname
WISE2C_IP_LABEL=$(cat /etc/hosts |grep -A 1 'BEGIN WISE2C DEPLOY MANAGED BLOCK' |grep -v '#' |grep -v '^\-\-' |wc |awk '{print $1}')

if [ "${WISE2C_IP_LABEL}" = "0" ]; then
  HOST_IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
  HOST_NAME=$(hostname)
else
  for IP_Addresses in $(cat /etc/hosts |grep -A 1 'BEGIN WISE2C DEPLOY MANAGED BLOCK' |grep -v '#' |grep -v '^\-\-' |awk '{print $1}');
  do
    GrepStr=$(ip a |grep "inet $IP_Addresses")
    if [ -n "$GrepStr" ]; then
      HOST_IP=$IP_Addresses
      HOST_NAME=$(cat /etc/hosts |grep -A 1 'BEGIN WISE2C DEPLOY MANAGED BLOCK' |grep -v '#' |grep -v '^\-\-' |grep $HOST_IP |awk '{print $2}')
    fi
  done;
fi

HOST_VIP=`cat /var/tmp/wise2c/kubernetes/kubeadm.conf | grep -A 1 SAN | tail -1 | awk '{print $2}'`

# K8S apiserver certificate
cd /var/tmp/wise2c/kubernetes
cfssl gencert -ca=/etc/kubernetes/pki/ca.crt -ca-key=/etc/kubernetes/pki/ca.key -config=ca-config.json -hostname=127.0.0.1,10.96.0.1,$HOST_IP,$HOST_VIP,$HOST_NAME,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster.local -profile=kubernetes apiserver-csr.json | cfssljson -bare apiserver

cd /var/tmp/wise2c/kubernetes/
mv apiserver.pem /etc/kubernetes/pki/apiserver.crt
mv apiserver-key.pem /etc/kubernetes/pki/apiserver.key
