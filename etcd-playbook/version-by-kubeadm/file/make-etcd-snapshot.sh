#!/bin/bash
set -e

etcdurl=`docker exec etcd ps -o args |grep -v args |grep -v COMMAND |awk '{print $7}'`
health=`docker exec etcd etcdctl --endpoints ${etcdurl} cluster-health |grep 'cluster is healthy'`
if [ "$health" = "cluster is healthy" ]; then
  echo cluster is healthy
  backuptime=`date +%F-%H-%M-%S`
  etcdurl=`docker exec etcd ps -o args |grep -v ps |grep -v COMMAND |awk '{print $7}'`
  etcdbackup=`docker exec -e ETCDCTL_API=3 etcd etcdctl --endpoints ${etcdurl} snapshot save snapshotdb-${backuptime} |awk '{print $4}'`
  docker cp etcd:/${etcdbackup} ./
  docker exec -it etcd rm -f /${etcdbackup}
else
  echo cluster is not healthy
  exit 1
fi
