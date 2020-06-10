#!/bin/bash
cd /var/lib/wise2c/tmp/istio/
IstioVersion=`cat components-version.txt |grep "Istio Version" |awk '{print $3}'`
cd istio-$IstioVersion/
istioctl manifest generate | kubectl delete -f -
kubectl delete ns istio-system
