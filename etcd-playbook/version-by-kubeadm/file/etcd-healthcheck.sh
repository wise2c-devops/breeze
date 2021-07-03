#!/bin/bash
etcdurl=`podman inspect etcd |grep -A1 "\-\-advertise-client-urls" |grep https |head -n 1 |awk -F'"' '{print $2}' |awk -F'=' '{print $2}'`
podman exec etcd etcdctl --cacert=/etcd-cert/ca.pem \
--cert=/etcd-cert/etcd.pem \
--key=/etcd-cert/etcd-key.pem \
--endpoints ${etcdurl} endpoint health |grep 'is healthy'
podman exec etcd etcdctl --cacert=/etcd-cert/ca.pem \
--cert=/etcd-cert/etcd.pem \
--key=/etcd-cert/etcd-key.pem \
--endpoints ${etcdurl} endpoint status --cluster -w table
