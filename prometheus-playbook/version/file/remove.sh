#!/bin/bash

cd /var/tmp/wise2c/prometheus
version_path=`more components-version.txt |grep "KubePrometheus Version" |awk '{print $3}'`

kubectl delete --ignore-not-found=true -f /var/tmp/wise2c/prometheus/kube-prometheus-${version_path}/manifests/
kubectl delete --ignore-not-found=true -f /var/tmp/wise2c/prometheus/kube-prometheus-${version_path}/manifests/setup
