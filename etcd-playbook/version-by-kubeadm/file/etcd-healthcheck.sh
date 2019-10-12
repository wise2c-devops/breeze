#!/bin/bash
etcdurl=`docker exec etcd ps -o args |grep -v args |grep -v COMMAND |awk '{print $7}'`
docker exec etcd etcdctl --ca-file=/etcd-cert/ca.pem \
--cert-file=/etcd-cert/etcd.pem \
--key-file=/etcd-cert/etcd-key.pem \
 --endpoints ${etcdurl} cluster-health |grep 'cluster is healthy'
