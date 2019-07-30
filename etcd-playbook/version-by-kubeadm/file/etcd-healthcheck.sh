#!/bin/bash
etcdurl=`docker exec etcd ps -o args |grep -v ps |grep -v COMMAND |awk '{print $7}'`
docker exec etcd etcdctl --endpoints ${etcdurl} cluster-health |grep 'cluster is healthy'
