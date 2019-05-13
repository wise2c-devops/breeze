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

# For offline deploy
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system

# Wait for CRDs to be ready, we need to verify that all 58 Istio CRDs were committed to the Kubernetes api-server using the following command:
# kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l

######### Deploy Istio #########
# Wait for CRDs to be ready.
printf "Waiting for Istio to commit custom resource definitions..."

until [ `kubectl get crds |grep 'istio.io\|certmanager.k8s.io' |wc -l` = "53" ]; do sleep 1; printf "."; done
echo 'Phase1 done!'

helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set gateways.istio-ingressgateway.type=NodePort --values install/kubernetes/helm/istio/values-istio-demo-auth.yaml

echo 'Phase2 done!'

#kubectl apply -f /var/tmp/wise2c/istio/prometheus-service.yaml
#kubectl apply -f /var/tmp/wise2c/istio/grafana-service.yaml

echo 'NodePorts are set for services.'
