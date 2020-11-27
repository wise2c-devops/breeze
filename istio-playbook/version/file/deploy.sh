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

#istioctl install --set profile=demo --set values.tracing.jaeger.hub=$MyImageRepositoryIP\/$MyImageRepositoryProject --set values.kiali.hub=$MyImageRepositoryIP\/$MyImageRepositoryProject --set values.prometheus.hub=$MyImageRepositoryIP\/$MyImageRepositoryProject --set values.grafana.image.repository=$MyImageRepositoryIP\/$MyImageRepositoryProject/grafana --set hub=$MyImageRepositoryIP\/$MyImageRepositoryProject

istioctl install -y --set profile=demo --set hub=$MyImageRepositoryIP\/$MyImageRepositoryProject

#kubectl apply -f /var/lib/wise2c/tmp/istio/kiali-service.yaml
#kubectl apply -f /var/lib/wise2c/tmp/istio/jaeger-service.yaml
#kubectl apply -f /var/lib/wise2c/tmp/istio/prometheus-service.yaml
#kubectl apply -f /var/lib/wise2c/tmp/istio/grafana-service.yaml

#echo 'NodePorts are set for services.'
