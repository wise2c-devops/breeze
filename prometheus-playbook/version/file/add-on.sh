#!/bin/bash
kubectl apply -f kube-controller-manager.yaml
kubectl apply -f kube-scheduler.yaml
kubectl apply -f coredns.yaml

etcd1_address=`cat etcd-address.txt |awk -F "," '{print $1}' |awk -F "//" '{print $2}' |awk -F ":" '{print $1}'`
etcd2_address=`cat etcd-address.txt |awk -F "," '{print $2}' |awk -F "//" '{print $2}' |awk -F ":" '{print $1}'`
etcd3_address=`cat etcd-address.txt |awk -F "," '{print $3}' |awk -F "//" '{print $2}' |awk -F ":" '{print $1}'`

sed -i "s/etcd_1_address/${etcd1_address}/g" /var/tmp/wise2c/prometheus/etcd.yaml
sed -i "s/etcd_2_address/${etcd2_address}/g" /var/tmp/wise2c/prometheus/etcd.yaml
sed -i "s/etcd_3_address/${etcd3_address}/g" /var/tmp/wise2c/prometheus/etcd.yaml

kubectl -n monitoring apply -f etcd.yaml
