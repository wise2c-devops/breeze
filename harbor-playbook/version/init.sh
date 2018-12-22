#! /bin/bash

set -e

path=`dirname $0`

version=`cat ${path}/components-version.txt |grep "Harbor" |awk '{print $3}'`

echo "" >> ${path}/yat/harbor.yml.gotmpl
echo "version: v${version}" >> ${path}/yat/harbor.yml.gotmpl

curl -L https://storage.googleapis.com/harbor-releases/release-${version}/harbor-offline-installer-v${version}.tgz \
    -o ${path}/file/harbor-offline-installer-v${version}.tgz

curl -sSL https://raw.githubusercontent.com/vmware/harbor/v${version}/make/harbor.cfg \
    | sed \
    -e "s,hostname = reg\.mydomain\.com,hostname = {{ inventory_hostname }},g" \
    -e "s,harbor_admin_password = Harbor12345,harbor_admin_password = {{ password }},g" \
    > ${path}/template/harbor.cfg.j2
