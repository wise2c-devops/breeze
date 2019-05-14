#!/bin/bash

set -e

MyImageRepositoryIP=`cat harbor-address.txt`
MyImageRepositoryProject=library
IstioVersion=`cat components-version.txt |grep "Istio Version" |awk '{print $3}'`

######### Push images #########
for file in $(cat images-list.txt); do docker tag $file $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images taged.'

for file in $(cat images-list.txt); do docker push $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images pushed.'

######### Update deploy yaml files #########
rm -rf istio-$IstioVersion
tar zxvf istio-$IstioVersion-origin.tar.gz
cd istio-$IstioVersion/install/kubernetes
sed -i "s/docker.io\/istio/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "docker.io/istio" ./ |grep .yaml)
sed -i "s/docker.io\/kiali/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "docker.io/kiali" ./ |grep .yaml)
sed -i "s/docker.io\/prom/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "docker.io/prom" ./ |grep .yaml)
sed -i "s/docker.io\/jaegertracing/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "docker.io/jaegertracing" ./ |grep .yaml)
sed -i "s/grafana\/grafana/$MyImageRepositoryIP\/$MyImageRepositoryProject\/grafana/g" $(grep -lr "grafana/grafana" ./ |grep .yaml)
cd ../../

# Istio init deploy
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system

######### Deploy Istio #########
# We need to verify that all 53 Istio CRDs were committed to the Kubernetes api-server
printf "Waiting for Istio to commit custom resource definitions..."

crdresult=""
for ((i=1; i<=53; i++)); do crdresult=${crdresult}"True"; done

until [ `for istiocrds in $(kubectl get crds |grep -v NAME |awk '{print $1}'); do kubectl get crd ${istiocrds} -o jsonpath='{.status.conditions[1].status}'; done` = $crdresult ]; do sleep 1; printf "."; done

echo 'Phase1 done!'

helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set gateways.istio-ingressgateway.type=NodePort --values install/kubernetes/helm/istio/values-istio-demo-auth.yaml

echo 'Phase2 done!'

kubectl apply -f /var/tmp/wise2c/istio/kiali-service.yaml
kubectl apply -f /var/tmp/wise2c/istio/jaeger-service.yaml
kubectl apply -f /var/tmp/wise2c/istio/prometheus-service.yaml
kubectl apply -f /var/tmp/wise2c/istio/grafana-service.yaml

echo 'NodePorts are set for services.'
