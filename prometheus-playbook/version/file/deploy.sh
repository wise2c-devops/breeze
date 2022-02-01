#!/bin/bash
set -e

#If seems that there is a bug on Ubuntu host to load the images. If no wait, it will return an error message: "Error response from daemon: No such image"
if [ ! -f /etc/redhat-release ]; then
  sleep 60
fi

MyImageRepositoryIP=`cat harbor-address.txt`
MyImageRepositoryProject=library
KubePrometheusVersion=`cat components-version.txt |grep "KubePrometheus" |awk '{print $3}'`
PrometheusOperatorVersion=`cat components-version.txt |grep "PrometheusOperator Version" |awk '{print $3}'`
NAMESPACE=monitoring

######### Push images #########
for file in $(cat images-list.txt); do podman tag $file $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images taged.'

for file in $(cat images-list.txt); do podman push $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images pushed.'
######### Update deploy yaml files #########
rm -rf kube-prometheus-$KubePrometheusVersion
tar zxf kube-prometheus-v$KubePrometheusVersion-origin.tar.gz
cd kube-prometheus-$KubePrometheusVersion

sed -i "s/quay.io\/prometheus-operator/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "quay.io/prometheus" ./ |grep .yaml)
sed -i "s/quay.io\/prometheus/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "image:" ./ |grep .yaml)
sed -i "s/quay.io\/brancz/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "image:" ./ |grep .yaml)
sed -i "s#directxman12\/#$MyImageRepositoryIP\/$MyImageRepositoryProject\/#g" $(grep -lr "image:" ./ |grep .yaml)
#sed -i "s/quay.io\/coreos/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "quay.io/coreos" ./ |grep .yaml)
sed -i "s/grafana\/grafana/$MyImageRepositoryIP\/$MyImageRepositoryProject\/grafana/g" $(grep -lr "grafana/grafana" ./ |grep .yaml)
sed -i "s/gcr.io\/google_containers/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "gcr.io/google_containers" ./ |grep .yaml)
sed -i "s/jimmidyson\/configmap-reload/$MyImageRepositoryIP\/$MyImageRepositoryProject\/configmap-reload/g" $(grep -lr "jimmidyson/configmap-reload" ./ |grep .yaml)
#sed -i "s/directxman12\/k8s-prometheus-adapter/$MyImageRepositoryIP\/$MyImageRepositoryProject\/k8s-prometheus-adapter/g" $(grep -lr "directxman12/k8s-prometheus-adapter" ./ |grep .yaml)
sed -i "s/k8s.gcr.io\/kube-state-metrics/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "k8s.gcr.io" ./ |grep .yaml)
sed -i "s/k8s.gcr.io\/prometheus-adapter/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "k8s.gcr.io/prometheus-adapter" ./ |grep .yaml)

cd ..
rm -f temp.txt

######### Update yaml files to supports K8s v1.16 #########
cd kube-prometheus-$KubePrometheusVersion/manifests/
sed -i "s#apps/v1beta2#apps/v1#g" $(ls *.yaml)
cd setup
sed -i "s#apps/v1beta2#apps/v1#g" $(ls *.yaml)
cd ../../

######### Deploy prometheus operator and kube-prometheus #########

# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
kubectl apply --server-side -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl apply -f manifests/

kubectl apply -f /var/lib/wise2c/tmp/prometheus/prometheus-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/prometheus/alertmanager-service.yaml
kubectl apply -f /var/lib/wise2c/tmp/prometheus/grafana-service.yaml

echo 'NodePorts are set for services.'
