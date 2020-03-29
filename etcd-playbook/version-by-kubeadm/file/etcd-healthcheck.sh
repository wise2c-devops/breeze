#!/bin/bash
etcdurl=`docker inspect etcd |grep -A1 "\-\-advertise-client-urls" |grep https |head -n 1 |awk -F'"' '{print $2}'`
docker exec etcd etcdctl --cacert=/etcd-cert/ca.pem \
--cert=/etcd-cert/etcd.pem \
--key=/etcd-cert/etcd-key.pem \
--endpoints ${etcdurl} endpoint health |grep 'is healthy'
