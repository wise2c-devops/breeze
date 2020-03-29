#!/bin/bash
set -e

etcdurl=`docker inspect etcd |grep -A1 "\-\-advertise-client-urls" |grep https |head -n 1 |awk -F'"' '{print $2}'`
docker exec etcd etcdctl --cacert=/etcd-cert/ca.pem --cert=/etcd-cert/etcd.pem --key=/etcd-cert/etcd-key.pem --endpoints ${etcdurl} endpoint health
if [ $? -eq 0 ]; then
  echo cluster is healthy
  backuptime=`date +%F-%H-%M-%S`
  etcdurl=`docker inspect etcd |grep -A1 "\-\-advertise-client-urls" |grep https |head -n 1 |awk -F'"' '{print $2}'`
  etcdbackup=`docker exec -e ETCDCTL_API=3 etcd etcdctl --cacert=/etcd-cert/ca.pem --cert=/etcd-cert/etcd.pem --key=/etcd-cert/etcd-key.pem --endpoints ${etcdurl} snapshot save snapshotdb-${backuptime} |awk '{print $4}'`
  docker cp etcd:/${etcdbackup} ./
  docker exec -it etcd rm -f /${etcdbackup}
else
  echo cluster is not healthy
  exit 1
fi
