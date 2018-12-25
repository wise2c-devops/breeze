#!/bin/bash

cd /var/tmp/wise2c/prometheus
version_path=`find ./ -name bundle.yaml |awk -F"/" '{print $2}'`

kubectl delete -f /var/tmp/wise2c/prometheus/${version_path}/contrib/kube-prometheus/manifests/phase2
kubectl delete -f /var/tmp/wise2c/prometheus/${version_path}/contrib/kube-prometheus/manifests/phase1


### To remove the operator and Prometheus, first delete any custom resources you created in each namespace. The operator will automatically shut down and remove Prometheus and Alertmanager pods, and associated ConfigMaps.

#for n in $(kubectl get namespaces -o jsonpath={..metadata.name}); do
#  kubectl delete --all --namespace=$n prometheus.monitoring.coreos.com
#done

#for n in $(kubectl get namespaces -o jsonpath={..metadata.name}); do
#  kubectl delete --all --namespace=$n servicemonitor.monitoring.coreos.com
#done

#for n in $(kubectl get namespaces -o jsonpath={..metadata.name}); do
#  kubectl delete --all --namespace=$n alertmanager.monitoring.coreos.com
#done

### After a couple of minutes you can go ahead and remove the operator itself.
#echo "Waiting for Operator to remove CRD objects prometheus..."
#while [[ $(kubectl get prometheus.monitoring.coreos.com --all-namespaces 2>&1) != "No resources found." ]] && [[ $(kubectl get prometheus.monitoring.coreos.com --all-namespaces 2>&1) != "error: the server doesn't have a resource type \"prometheus\"" ]]
#do
#  sleep 1
#  printf "."
#done

#echo "Waiting for Operator to remove CRD objects servicemonitor..."
#while [[ $(kubectl get servicemonitor.monitoring.coreos.com --all-namespaces 2>&1) != "No resources found." ]] && [[ $(kubectl get servicemonitor.monitoring.coreos.com --all-namespaces 2>&1) != "error: the server doesn't have a resource type \"servicemonitor\"" ]]
#do 
#  sleep 1
#  printf "."
#done

#echo "Waiting for Operator to remove CRD objects alertmanager..."
#while [[ $(kubectl get alertmanager.monitoring.coreos.com --all-namespaces 2>&1) != "No resources found." ]] && [[ $(kubectl get alertmanager.monitoring.coreos.com --all-namespaces 2>&1) != "error: the server doesn't have a resource type \"alertmanager\"" ]]
#do 
#  sleep 1
#  printf "."
#done

#printf "Waiting for Operator to remove custom resource definitions..."
#while [[ $(kubectl get customresourcedefinitions prometheus.monitoring.coreos.com --all-namespaces 2>&1) != "No resources found." ]] && [[ $(kubectl get customresourcedefinitions prometheus.monitoring.coreos.com --all-namespaces 2>&1) != "error: the server doesn't have a resource type \"prometheus\"" ]]
#do
#  sleep 1
#  printf "."
#done

#printf "Waiting for Operator to remove custom resource definitions..."
#while [[ $(kubectl get customresourcedefinitions servicemonitor.monitoring.coreos.com --all-namespaces 2>&1) != "No resources found." ]] && [[ $(kubectl get customresourcedefinitions servicemonitor.monitoring.coreos.com --all-namespaces 2>&1) != "error: the server doesn't have a resource type \"servicemonitor\"" ]]
#do
#  sleep 1
#  printf "."
#done

#printf "Waiting for Operator to remove custom resource definitions..."
#while [[ $(kubectl get customresourcedefinitions alertmanager.monitoring.coreos.com --all-namespaces 2>&1) != "No resources found." ]] && [[ $(kubectl get customresourcedefinitions alertmanager.monitoring.coreos.com --all-namespaces 2>&1) != "error: the server doesn't have a resource type \"alertmanager\"" ]]
#do
#  sleep 1
#  printf "."
#done

### The operator automatically creates services in each namespace where you created a Prometheus or Alertmanager resources, and defines three custom resource definitions. You can clean these up now.
#for n in $(kubectl get namespaces -o jsonpath={..metadata.name}); do
#  kubectl delete --ignore-not-found --namespace=$n service prometheus-operated alertmanager-operated
#done

#kubectl delete --ignore-not-found customresourcedefinitions \
#  prometheuses.monitoring.coreos.com \
#  servicemonitors.monitoring.coreos.com \
#  alertmanagers.monitoring.coreos.com

#kubectl delete ns monitoring
