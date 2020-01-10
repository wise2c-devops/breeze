#!/bin/bash
TIME_STRING=`date "+%Y-%m-%d-%H-%M-%S"`
cd /etc/kubernetes/
cp -p /etc/kubernetes/kubelet.conf /etc/kubernetes/kubelet.conf.$TIME_STRING
sed -i 's#client-certificate-data:.*$#client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem#g' kubelet.conf 
sed -i 's#client-key-data:.*$#client-key: /var/lib/kubelet/pki/kubelet-client-current.pem#g' kubelet.conf
systemctl restart kubelet
