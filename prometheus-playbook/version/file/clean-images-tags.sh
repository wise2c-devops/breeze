#!/bin/bash
cd /var/tmp/wise2c/prometheus
for file in $(cat images-list.txt); do docker rmi $file ; done
