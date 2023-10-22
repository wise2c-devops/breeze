#! /bin/bash

set -e

path=`dirname $0`

image=registry.k8s.io/etcd:${1}
echo "" >> ${path}/group_vars/etcd.yml
echo "version: ${1}" >> ${path}/group_vars/etcd.yml

echo "etcd_version: ${1}" >> ${path}/inherent.yaml

docker pull ${image}
docker save ${image} > ${path}/file/etcd.tar
bzip2 -z --best ${path}/file/etcd.tar

export CPUArch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64") print "arm64"; else print $1 }')

echo "=== download cfssl tools ==="
export CFSSL_VERSION=1.6.4
export CFSSL_URL=https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}
curl -L -o cfssl ${CFSSL_URL}/cfssl_${CFSSL_VERSION}_linux_${CPUArch}
curl -L -o cfssljson ${CFSSL_URL}/cfssljson_${CFSSL_VERSION}_linux_${CPUArch}
curl -L -o cfssl-certinfo ${CFSSL_URL}/cfssl-certinfo_${CFSSL_VERSION}_linux_${CPUArch}
chmod +x cfssl cfssljson cfssl-certinfo
tar zcvf ${path}/file/cfssl-tools.tar.gz cfssl cfssl-certinfo cfssljson
echo "=== cfssl tools is download successfully ==="
