#! /bin/bash
set -e
path=`dirname $0`

echo "build wise2c/k8s-keepalived:1.3.5 image"
cd ${path}/keepalived
docker build -t wise2c/k8s-keepalived:1.3.5 .
docker save wise2c/k8s-keepalived:1.3.5 -o ../file/keepalived-1.3.5.tar
bzip2 -z --best ../file/keepalived-1.3.5.tar

echo "build wise2c/k8s-haproxy:1.8.14 image"
docker pull haproxy:1.8.14
docker tag haproxy:1.8.14 wise2c/k8s-haproxy:1.8.14
docker save wise2c/k8s-haproxy:1.8.14 -o ../file/haproxy-1.8.14.tar
bzip2 -z --best ../file/haproxy-1.8.14.tar
