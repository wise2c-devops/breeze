#!/bin/bash

cd /var/lib/wise2c/tmp/prometheus
version_path=`more components-version.txt |grep "KubePrometheus Version" |awk '{print $3}'`

kubectl delete --ignore-not-found=true -f /var/lib/wise2c/tmp/prometheus/kube-prometheus-${version_path}/manifests/
kubectl delete --ignore-not-found=true -f /var/lib/wise2c/tmp/prometheus/kube-prometheus-${version_path}/manifests/setup
