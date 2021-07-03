#! /bin/bash
if [ -e '/var/run/docker.sock' ]; then
  docker_installed=`curl -sS --unix-socket /var/run/docker.sock http:/v1.24/info | jq -r '.RegistryConfig.IndexConfigs."'docker.io'".Name'`
  if [ "${docker_installed}" == "docker.io" ]; then
    echo -n true
  else
    # docker.sock is exists but docker service is not started
    if [ -e '/etc/containers/registries.conf' ]; then
      insecure_harbor=`cat /etc/containers/registries.conf |grep $1 |awk -F'=' '{print $2}' |awk -F'"' '{print $2}'`
      if [ "${insecure_harbor}" == "$1" ]; then
        if [ -e '/var/run/crio/crio.sock' ]; then
          cgroup_manager=`curl -sS --unix-socket /var/run/crio/crio.sock http://localhost/config |grep cgroup_manager |awk -F '"' '{print $2}'`
          if [ "${cgroup_manager}" == "systemd" ]; then
            echo -n true
          else
            # crio.sock is exists but crio service is not started
            echo -n false
          fi
        else
          # crio.sock is not exists
          echo -n false
        fi
      else
        # crio is not installed with Breeze
        echo -n false
      fi
    else
      # crio is not installed
      echo -n false
    fi
  fi
else
  # docker is not installed
  if [ -e '/etc/containers/registries.conf' ]; then
    insecure_harbor=`cat /etc/containers/registries.conf |grep $1 |awk -F'=' '{print $2}' |awk -F'"' '{print $2}'`
    if [ "${insecure_harbor}" == "$1" ]; then
      if [ -e '/var/run/crio/crio.sock' ]; then
        cgroup_manager=`curl -sS --unix-socket /var/run/crio/crio.sock http://localhost/config |grep cgroup_manager |awk -F '"' '{print $2}'`
        if [ "${cgroup_manager}" == "systemd" ]; then
          echo -n true
        else
          # crio.sock is exists but crio service is not started
          echo -n false
        fi
      else
        # crio.sock is not exists
        echo -n false
      fi
    else
      # crio is not installed with Breeze
      echo -n false
    fi
  else
    # crio is not installed
    echo -n false
  fi
fi
