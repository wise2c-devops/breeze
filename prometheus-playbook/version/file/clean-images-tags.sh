#!/bin/bash
cd /var/lib/wise2c/tmp/prometheus
for file in $(cat images-list.txt); do podman rmi $file ; done
