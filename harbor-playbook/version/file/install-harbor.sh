#!/bin/bash
sed -i '0,/https:/s//# https:/' harbor.yml
sed -i 's,port: 443,# port: 443,g' harbor.yml
sed -i 's,certificate:,# certificate:,g' harbor.yml
sed -i 's,private_key:,# private_key:,g' harbor.yml

./install.sh

#fix the bug for ARM64 packages
export CPUArch=$(uname -m | awk '{ if ($1 == "x86_64") print "amd64"; else if ($1 == "aarch64") print "arm64"; else print $1 }')

if [ $CPUArch == 'aarch64' ]
then
  chmod -R 777 /data/redis
fi
