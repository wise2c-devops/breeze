#! /bin/bash

set -e

path=`dirname $0`

version=`cat ${path}/components-version.txt |grep "Harbor" |awk '{print $3}'`

echo "" >> ${path}/yat/harbor.yml.gotmpl
echo "version: v${version}" >> ${path}/yat/harbor.yml.gotmpl

curl -L https://github.com/docker/compose/releases/download/2.24.6/docker-compose-$(uname -s)-$(uname -m) -o ${path}/file/docker-compose

export CPUArch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64") print "arm64"; else print $1 }')

if [ $CPUArch == 'amd64' ]
then
   curl -L https://storage.googleapis.com/harbor-releases/release-${version%.*}.0/harbor-offline-installer-v${version}.tgz \
    -o ${path}/file/harbor-offline-installer-v${version}.tgz
else
  curl -L https://github.com/wise2c-devops/build-harbor-aarch64/releases/download/v${version}/harbor-offline-installer-aarch64-v${version}.tgz \
    -o ${path}/file/harbor-offline-installer-v${version}.tgz
fi

curl -sSL https://raw.githubusercontent.com/vmware/harbor/v${version}/make/harbor.yml.tmpl \
    | sed \
    -e "s,hostname: reg\.mydomain\.com,hostname: {{ inventory_hostname }},g" \
    -e "s,harbor_admin_password: Harbor12345,harbor_admin_password: {{ password }},g" \
    > ${path}/template/harbor.yml.j2
