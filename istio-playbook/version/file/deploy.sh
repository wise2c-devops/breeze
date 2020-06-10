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

######### Update deploy yaml files #########
rm -rf istio-$IstioVersion
tar zxvf istio-$IstioVersion-origin.tar.gz
cd istio-$IstioVersion/

sed -i "s/quay.io\/kiali/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" samples/addons/kiali.yaml
sed -i "s/docker.io\/jaegertracing/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" samples/addons/jaeger.yaml
sed -i "s/openzipkin\/zipkin-slim/$MyImageRepositoryIP\/$MyImageRepositoryProject\/zipkin-slim/g" samples/addons/extras/zipkin.yaml
sed -i "s/prom\/prometheus/$MyImageRepositoryIP\/$MyImageRepositoryProject\/prometheus/g" samples/addons/prometheus.yaml
sed -i "s/jimmidyson\/configmap-reload/$MyImageRepositoryIP\/$MyImageRepositoryProject\/configmap-reload/g" samples/addons/prometheus.yaml
sed -i "s/grafana\/grafana/$MyImageRepositoryIP\/$MyImageRepositoryProject\/grafana/g" samples/addons/grafana.yaml

sed -i "s/hub: docker.io\/istio/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/profiles/default.yaml
sed -i "s/hub: docker.io\/prom/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/profiles/default.yaml
sed -i "s/hub: docker.io\/jaegertracing/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/profiles/default.yaml
sed -i "s/hub: docker.io\/openzipkin/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/profiles/default.yaml
sed -i "s/hub: docker.io\/omnition/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/profiles/default.yaml
sed -i "s/hub: quay.io\/kiali/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/profiles/default.yaml
sed -i "s/hub: quay.io\/kiali/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/charts/istio-telemetry/kiali/values.yaml
sed -i "s/hub: docker.io\/jaegertracing/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/charts/istio-telemetry/tracing/values.yaml 
sed -i "s/hub: docker.io\/openzipkin/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/charts/istio-telemetry/tracing/values.yaml
sed -i "s/hub: docker.io\/omnition/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/charts/istio-telemetry/tracing/values.yaml
sed -i "s/hub: docker.io\/prom/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/charts/istio-telemetry/prometheusOperator/values.yaml
sed -i "s/hub: docker.io\/prom/hub: $MyImageRepositoryIP\/$MyImageRepositoryProject/g" manifests/charts/istio-telemetry/prometheus/values.yaml

# Istio init deploy
rm -f /usr/bin/istioctl
cp bin/istioctl /usr/bin/
istioctl install --set profile=demo --set hub=$MyImageRepositoryIP\/$MyImageRepositoryProject

kubectl apply -f /var/lib/wise2c/tmp/istio/kiali-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/istio/jaeger-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/istio/prometheus-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/istio/grafana-service.yaml

echo 'NodePorts are set for services.'
