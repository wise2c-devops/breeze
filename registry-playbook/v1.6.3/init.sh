#! /bin/bash

set -e

path=`dirname $0`
version=$1
echo "" >> ${path}/yat/registry.yml.gotmpl
echo "version: ${version}" >> ${path}/yat/registry.yml.gotmpl

curl -L https://storage.googleapis.com/harbor-releases/harbor-offline-installer-${version}.tgz \
    -o ${path}/file/harbor-offline-installer-${version}.tgz

curl -sSL https://raw.githubusercontent.com/vmware/harbor/${version}/make/harbor.cfg \
    | sed \
    -e "s,hostname = reg\.mydomain\.com,hostname = {{ inventory_hostname }},g" \
    -e "s,harbor_admin_password = Harbor12345,harbor_admin_password = {{ password }},g" \
    > ${path}/template/harbor.cfg.j2
