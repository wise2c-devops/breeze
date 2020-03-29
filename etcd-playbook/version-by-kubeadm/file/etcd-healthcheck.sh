#!/bin/bash
etcdurl=`docker inspect etcd |grep -A1 "\-\-advertise-client-urls" |grep https |head -n 1 |awk -F'"' '{print $2}'`
docker exec etcd etcdctl --ca-file=/etcd-cert/ca.pem \
--cert-file=/etcd-cert/etcd.pem \
--key-file=/etcd-cert/etcd-key.pem \
 --endpoints ${etcdurl} cluster-health |grep 'cluster is healthy'
