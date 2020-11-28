#!/bin/bash
set -e

#It seems that there is a bug on Ubuntu host to load the images. If no wait, it will return an error message: "Error response from daemon: No such image"
sleep 60

MyImageRepositoryIP=`cat harbor-address.txt`
MyImageRepositoryProject=library
IstioVersion=`cat components-version.txt |grep "Istio Version" |awk '{print $3}'`

######### Push images #########
for file in $(cat images-list.txt); do docker tag $file $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images taged.'

for file in $(cat images-list.txt); do docker push $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images pushed.'

# Istio deploy
rm -rf istio-$IstioVersion
tar zxvf istio-$IstioVersion-origin.tar.gz
cd istio-$IstioVersion/
rm -f /usr/bin/istioctl
cp bin/istioctl /usr/bin/

istioctl install -y --set profile=demo --set hub=$MyImageRepositoryIP\/$MyImageRepositoryProject

sed -i "s,image: \"grafana/,image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/grafana.yaml
sed -i "s,image: \"docker.io/jaegertracing/,image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/jaeger.yaml 
sed -i "s,image: \"prom/,image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/prometheus.yaml
sed -i "s,image: \"jimmidyson/,image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/prometheus.yaml
sed -i "s,- image: \"quay.io/kiali/,- image: \"$MyImageRepositoryIP/$MyImageRepositoryProject/,g" samples/addons/kiali.yaml
sed -i "s,strategy: anonymous,strategy: token,g" samples/addons/kiali.yaml

kubectl apply -f samples/addons/
            
kubectl apply -f /var/lib/wise2c/tmp/istio/kiali-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/istio/jaeger-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/istio/prometheus-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/istio/grafana-service.yaml

echo 'NodePorts have been set for services.'
