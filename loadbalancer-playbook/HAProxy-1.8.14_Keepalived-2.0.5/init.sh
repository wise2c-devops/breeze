#! /bin/bash
set -e
path=`dirname $0`

echo "build wise2c/k8s-keepalived:2.0.5 image"
cd ${path}/keepalived
docker build -t wise2c/k8s-keepalived:2.0.5 .
cd ..
docker save wise2c/k8s-keepalived:2.0.5 -o ${path}/file/keepalived-2.0.5.tar
bzip2 -z --best ${path}/keepalived-2.0.5.tar

echo "build wise2c/k8s-haproxy:1.8.14 image"
docker pull haproxy:1.8.14
docker tag haproxy:1.8.14 wise2c/k8s-haproxy:1.8.14
docker save wise2c/k8s-haproxy:1.8.14 -o ${path}/file/haproxy-1.8.14.tar
bzip2 -z --best ${path}/haproxy-1.8.14.tar
