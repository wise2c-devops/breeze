#!/bin/bash
set -e

etcdurl=`podman inspect etcd |grep -A1 "\-\-advertise-client-urls" |grep https |head -n 1 |awk -F'"' '{print $2}' |awk -F'=' '{print $2}'`
podman exec etcd etcdctl --cacert=/etcd-cert/ca.pem --cert=/etcd-cert/etcd.pem --key=/etcd-cert/etcd-key.pem --endpoints ${etcdurl} endpoint health
if [ $? -eq 0 ]; then
  echo cluster is healthy
  backuptime=`date +%F-%H-%M-%S`
  etcdurl=`podman inspect etcd |grep -A1 "\-\-advertise-client-urls" |grep https |head -n 1 |awk -F'"' '{print $2}' |awk -F'=' '{print $2}'`
  etcdbackup=`podman exec -e ETCDCTL_API=3 etcd etcdctl --cacert=/etcd-cert/ca.pem --cert=/etcd-cert/etcd.pem --key=/etcd-cert/etcd-key.pem --endpoints ${etcdurl} snapshot save snapshotdb-${backuptime} |awk '{print $4}'`
  podman cp etcd:/${etcdbackup} ./
else
  echo cluster is not healthy
  exit 1
fi
