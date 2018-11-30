#! /bin/bash
set -e
path=`dirname $0`

echo "build wise2c/k8s-keepalived:2.0.5 image"
#docker pull wise2c/keepalived-k8s
cd keepalived
docker build -t wise2c/k8s-keepalived:2.0.5 .
#docker tag wise2c/keepalived-k8s wise2c/k8s-keepalived:2.0.5
docker save wise2c/k8s-keepalived:2.0.5 -o keepalived-2.0.5.tar
bzip2 -z --best keepalived-2.0.5.tar
mv keepalived-2.0.5.tar.bz2 ${path}/file/

echo "build wise2c/k8s-haproxy:1.8.14 image"
docker pull haproxy:1.8.14
docker tag haproxy:1.8.14 wise2c/k8s-haproxy:1.8.14
docker save wise2c/k8s-haproxy:1.8.14 -o haproxy-1.8.14.tar
bzip2 -z --best haproxy-1.8.14.tar
mv haproxy-1.8.14.tar.bz2 ${path}/file/
