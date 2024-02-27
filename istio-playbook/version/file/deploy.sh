#!/bin/bash
set -e

#It seems that there is a bug on Ubuntu host to load the images. If no wait, it will return an error message: "Error response from daemon: No such image"
#if [ ! -f /etc/redhat-release ]; then
#  sleep 60
#fi

MyImageRepositoryIP=`cat harbor-address.txt`
MyImageRepositoryProject=library
IstioVersion=`cat components-version.txt |grep "Istio Version" |awk '{print $3}'`

######### Push images #########
cat images-list.txt |grep -v quay.io/ > images-list-crio.txt
sed -i 's#podman.io/##g' images-list-crio.txt
cat images-list.txt |grep "quay.io\/" > images-list-quay.txt

for file in $(cat images-list-crio.txt); do podman tag $file $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done
for file in $(cat images-list-quay.txt); do podman tag $file $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images taged.'

for file in $(cat images-list-crio.txt); do podman push $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done
for file in $(cat images-list-quay.txt); do podman push $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images pushed.'

# Istio deploy
rm -rf istio-$IstioVersion
tar zxvf istio-$IstioVersion-origin.tar.gz
cd istio-$IstioVersion/
rm -f /usr/bin/istioctl
cp bin/istioctl /usr/bin/

istioctl install -y --set profile=demo --set hub=$MyImageRepositoryIP\/$MyImageRepositoryProject

sed -i "s,image: \"grafana/,image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/grafana.yaml
sed -i "s,image: \"podman.io/jaegertracing/,image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/jaeger.yaml
sed -i "s,image: \"prom/,image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/prometheus.yaml
sed -i "s,image: \"jimmidyson/,image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/prometheus.yaml
sed -i "s,- image: \"quay.io/kiali/,- image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/kiali.yaml
sed -i "s,strategy: anonymous,strategy: token,g" samples/addons/kiali.yaml

set +e
# We need to verify that all 15 Istio CRDs were committed to the Kubernetes api-server
printf "Waiting for Istio to commit custom resource definitions..."

until [ `kubectl get crds |grep 'istio.io\|certmanager.k8s.io' |wc -l` -eq 15 ]; do printf "."; done

crdresult=""
for ((i=1; i<=15; i++)); do crdresult=${crdresult}"True"; done

until [ `for istiocrds in $(kubectl get crds |grep 'istio.io\|certmanager.k8s.io' |awk '{print $1}'); do kubectl get crd ${istiocrds} -o jsonpath='{.status.conditions[1].status}'; done` = $crdresult ]; do sleep 1; printf "."; done

echo 'Istio CRD is ready!'

kubectl apply -f samples/addons/kiali.yaml
kubectl apply -f samples/addons/prometheus.yaml
kubectl apply -f samples/addons/grafana.yaml  
kubectl apply -f samples/addons/jaeger.yaml  
#kubectl apply -f samples/addons/prometheus_vm.yaml
#kubectl apply -f samples/addons/prometheus_vm_tls.yaml

set -e

kubectl apply -f /var/lib/wise2c/tmp/istio/kiali-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/istio/jaeger-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/istio/prometheus-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/istio/grafana-service.yaml

echo 'NodePorts have been set for services.'
