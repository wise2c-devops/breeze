#! /bin/bash

name=`curl -sS --unix-socket /var/run/docker.sock http:/v1.24/info | jq -r '.RegistryConfig.IndexConfigs."'$1'".Name'`
if [ "${name}" == "$1" ]; then
echo -n true
else
echo -n false
fi