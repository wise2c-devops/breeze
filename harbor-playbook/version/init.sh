#! /bin/bash

set -e

path=`dirname $0`

version=`cat ${path}/components-version.txt |grep "Harbor" |awk '{print $3}'`

echo "" >> ${path}/yat/harbor.yml.gotmpl
echo "version: v${version}" >> ${path}/yat/harbor.yml.gotmpl

curl -L https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m) -o ${path}/file/docker-compose

arch=$(uname -m)
if [ "$arch" == "x86_64" ]; then
  curl -L https://storage.googleapis.com/harbor-releases/release-${version%.*}.0/harbor-offline-installer-v${version}.tgz \
    -o ${path}/file/harbor-offline-installer-v${version}.tgz
elif [ "$arch" == "aarch64" ]; then
  echo 'Start to fetch harbor aarch64 packages ...'
  docker pull alanpeng/harbor_images_aarch64:v2.7.2
  TEMP_CONTAINER_ID=$(docker create alanpeng/harbor_images_aarch64:v2.7.2 /bin/true)
  docker cp $TEMP_CONTAINER_ID:/harbor-offline-installer-aarch64.tgz ${path}/file/harbor-offline-installer-v${version}.tgz
  docker rm $TEMP_CONTAINER_ID
  echo 'Harbor aarch64 packages is downloaded.'
else
  echo "Unsupported architectures: $arch"
  exit 1
fi

curl -sSL https://raw.githubusercontent.com/vmware/harbor/v${version}/make/harbor.yml.tmpl \
    | sed \
    -e "s,hostname: reg\.mydomain\.com,hostname: {{ inventory_hostname }},g" \
    -e "s,harbor_admin_password: Harbor12345,harbor_admin_password: {{ password }},g" \
    > ${path}/template/harbor.yml.j2
