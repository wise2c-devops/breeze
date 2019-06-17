#! /bin/bash
set -e
path=`dirname $0`

haproxy_version=`cat ${path}/components-version.txt |grep "HAProxy" |awk '{print $3}'`
keepalived_version=`cat ${path}/components-version.txt |grep "Keepalived" |awk '{print $3}'`

echo "haproxy_version: ${haproxy_version}" > ${path}/inherent.yaml
echo "keepalived_version: ${keepalived_version}" >> ${path}/inherent.yaml

echo "build wise2c/k8s-keepalived:${keepalived_version} image"
cd ${path}/keepalived
docker build -t wise2c/k8s-keepalived:${keepalived_version} .
docker save wise2c/k8s-keepalived:${keepalived_version} -o ../file/keepalived-${keepalived_version}.tar
bzip2 -z --best ../file/keepalived-${keepalived_version}.tar

echo "build wise2c/k8s-haproxy:${haproxy_version} image"
docker pull haproxy:${haproxy_version}
docker tag haproxy:${haproxy_version} wise2c/k8s-haproxy:${haproxy_version}
docker save wise2c/k8s-haproxy:${haproxy_version} -o ../file/haproxy-${haproxy_version}.tar
bzip2 -z --best ../file/haproxy-${haproxy_version}.tar
