#!/bin/bash
set -e

etcdurl=`docker exec etcd ps -o args |grep -v ps |grep -v COMMAND |awk '{print $7}'`
health=`docker exec etcd etcdctl --endpoints ${etcdurl} cluster-health |grep 'cluster is healthy'`
if [ "$health" = "cluster is healthy" ]; then
  echo cluster is healthy
  cp -pr /data/etcd /data/etcd-backup-`date +%F-%H-%M-%S`
else
  echo cluster is not healthy
  exit 1
fi
