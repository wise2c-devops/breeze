#!/bin/bash
cd /var/lib/wise2c/tmp/istio
for file in $(cat images-list.txt); do docker rmi $file ; done
