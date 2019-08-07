#!/bin/bash
etcdurl=`docker exec etcd ps -o args |grep -v args |grep -v COMMAND |awk '{print $7}'`
docker exec etcd etcdctl --endpoints ${etcdurl} cluster-health |grep 'cluster is healthy'
