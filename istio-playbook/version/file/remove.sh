#!/bin/bash
helm delete --purge istio
helm delete --purge istio-init
kubectl delete -f /var/tmp/wise2c/istio/istio-*/install/kubernetes/helm/istio-init/files
kubectl delete ns istio-system
