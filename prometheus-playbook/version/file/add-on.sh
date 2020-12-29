#!/bin/bash
KubePrometheusVersion=`cat components-version.txt |grep "KubePrometheus" |awk '{print $3}'`

kubectl apply -f kube-controller-manager.yaml
kubectl apply -f kube-scheduler.yaml
kubectl apply -f coredns.yaml

etcd1_address=`cat etcd-address.txt |awk -F "," '{print $1}' |awk -F "//" '{print $2}' |awk -F ":" '{print $1}'`
etcd2_address=`cat etcd-address.txt |awk -F "," '{print $2}' |awk -F "//" '{print $2}' |awk -F ":" '{print $1}'`
etcd3_address=`cat etcd-address.txt |awk -F "," '{print $3}' |awk -F "//" '{print $2}' |awk -F ":" '{print $1}'`

sed -i "s/etcd_1_address/${etcd1_address}/g" /var/lib/wise2c/tmp/prometheus/etcd.yaml
sed -i "s/etcd_2_address/${etcd2_address}/g" /var/lib/wise2c/tmp/prometheus/etcd.yaml
sed -i "s/etcd_3_address/${etcd3_address}/g" /var/lib/wise2c/tmp/prometheus/etcd.yaml

kubectl -n monitoring create secret generic etcd-certs --from-file=/etc/etcd/pki/ca.pem --from-file=/etc/etcd/pki/etcd.pem --from-file=/etc/etcd/pki/etcd-key.pem

cat >> kube-prometheus-$KubePrometheusVersion/manifests/prometheus-prometheus.yaml << EOF
  secrets:
  - etcd-certs
EOF

kubectl -n monitoring apply -f kube-prometheus-$KubePrometheusVersion/manifests/prometheus-prometheus.yaml

kubectl -n monitoring apply -f etcd.yaml
