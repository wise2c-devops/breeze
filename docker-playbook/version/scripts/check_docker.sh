#! /bin/bash

insecure_harbor=`curl -sS --unix-socket /var/run/docker.sock http:/v1.24/info | jq -r '.RegistryConfig.IndexConfigs."'$1'".Name'`
if [ "${insecure_harbor}" == "$1" ]; then
  echo -n true
else
  driver=`curl -sS --unix-socket /var/run/docker.sock http:/v1.24/info | jq -r .Driver`
  cgroupdriver=`curl -sS --unix-socket /var/run/docker.sock http:/v1.24/info | jq -r .CgroupDriver`
  if [ ${driver} == 'overlay2' ] && [ ${cgroupdriver} == 'systemd' ]; then
    echo -n true
  else
    echo -n false
  fi
fi
