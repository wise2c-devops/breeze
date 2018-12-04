#!/bin/bash
# Get host IP address and hostname
HOST_IP={{ ansible_default_ipv4.address }}
HOST_NAME=$(hostname)

HOST_VIP=`cat /var/tmp/wise2c/kubernetes/kubeadm.conf | grep -A 1 SAN | tail -1 | awk '{print $2}'`

# K8S apiserver certificate
cd /var/tmp/wise2c/kubernetes
cfssl gencert -ca=/etc/kubernetes/pki/ca.crt -ca-key=/etc/kubernetes/pki/ca.key -config=ca-config.json -hostname=127.0.0.1,10.96.0.1,$HOST_IP,$HOST_VIP,$HOST_NAME,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster.local -profile=kubernetes apiserver-csr.json | cfssljson -bare apiserver

cd /var/tmp/wise2c/kubernetes/
mv apiserver.pem /etc/kubernetes/pki/apiserver.crt
mv apiserver-key.pem /etc/kubernetes/pki/apiserver.key
