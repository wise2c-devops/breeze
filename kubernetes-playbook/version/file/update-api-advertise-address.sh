#!/bin/bash
set +e

# Get host IP address
WISE2C_IP_LABEL=$(cat /etc/hosts |grep -A 1 'BEGIN WISE2C DEPLOY MANAGED BLOCK' |grep -v '#' |grep -v '^\-\-' |wc |awk '{print $1}')

if [ "${WISE2C_IP_LABEL}" = "0" ]; then
  HOST_IP=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
else
  for IP_Addresses in $(cat /etc/hosts |grep -A 1 'BEGIN WISE2C DEPLOY MANAGED BLOCK' |grep -v '#' |grep -v '^\-\-' |awk '{print $1}');
  do
    GrepStr=$(ip a |grep -w "inet $IP_Addresses")
    if [ -n "$GrepStr" ]; then
      HOST_IP=$IP_Addresses
    fi
  done;
fi

sed -i "s/advertiseAddress: 127.0.0.1/advertiseAddress: ${HOST_IP}/g" kubeadm.conf
