#!/bin/bash
set -e

MyImageRepositoryIP=`cat harbor-address.txt`
MyImageRepositoryProject=library
KubePrometheusVersion=`cat components-version.txt |grep "KubePrometheus" |awk '{print $3}'`
PrometheusOperatorVersion=`cat components-version.txt |grep "PrometheusOperator Version" |awk '{print $3}'`
NAMESPACE=monitoring

######### Push images #########
for file in $(cat images-list.txt); do docker tag $file $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images taged.'

for file in $(cat images-list.txt); do docker push $MyImageRepositoryIP/$MyImageRepositoryProject/${file##*/}; done

echo 'Images pushed.'
######### Update deploy yaml files #########
rm -rf kube-prometheus-$KubePrometheusVersion
tar zxvf kube-prometheus-v$KubePrometheusVersion-origin.tar.gz
cd kube-prometheus-$KubePrometheusVersion
sed -i "s/quay.io\/coreos/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "quay.io/coreos" ./ |grep .yaml)
sed -i "s/quay.io\/prometheus/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "quay.io/prometheus" ./ |grep .yaml)
sed -i "s/grafana\/grafana/$MyImageRepositoryIP\/$MyImageRepositoryProject\/grafana/g" $(grep -lr "grafana/grafana" ./ |grep .yaml)
sed -i "s/gcr.io\/google_containers/$MyImageRepositoryIP\/$MyImageRepositoryProject/g" $(grep -lr "gcr.io/google_containers" ./ |grep .yaml)

# For offline deploy
cd ..
rm -f temp.txt
cp -p append-lines.txt temp.txt
sed -i "s/ImageRepositoryIP/$MyImageRepositoryIP/g" temp.txt
sed -i '23 r temp.txt' kube-prometheus-$KubePrometheusVersion/manifests/0prometheus-operator-deployment.yaml
rm -f temp.txt

# Fix issue 2291 of prometheus operator
sed -i "s/0.29.0/$PrometheusOperatorVersion/g" kube-prometheus-$KubePrometheusVersion/manifests/0prometheus-operator-deployment.yaml

# Wait for CRDs to be ready, we need to split all yaml files to two parts
cd kube-prometheus-$KubePrometheusVersion/
mkdir phase2
mv manifests/0prometheus-operator-serviceMonitor.yaml phase2/
mv manifests/alertmanager-alertmanager.yaml phase2/
mv manifests/alertmanager-serviceMonitor.yaml phase2/
mv manifests/kube-state-metrics-serviceMonitor.yaml phase2/
mv manifests/node-exporter-serviceMonitor.yaml phase2/
mv manifests/prometheus-prometheus.yaml phase2/
mv manifests/prometheus-rules.yaml phase2/
mv manifests/prometheus-serviceMonitor.yaml phase2/
mv manifests/prometheus-serviceMonitorApiserver.yaml phase2/
mv manifests/prometheus-serviceMonitorCoreDNS.yaml phase2/
mv manifests/prometheus-serviceMonitorKubeControllerManager.yaml phase2/
mv manifests/prometheus-serviceMonitorKubeScheduler.yaml phase2/
mv manifests/prometheus-serviceMonitorKubelet.yaml phase2/
mv manifests/grafana-serviceMonitor.yaml phase2/
mv manifests phase1
mkdir manifests
mv phase1 manifests
mv phase2 manifests

######### Deploy prometheus operator and kube-prometheus #########

kctl() {
    kubectl --namespace "$NAMESPACE" "$@"
}

kubectl apply -f manifests/phase1

# Wait for CRDs to be ready.
printf "Waiting for Operator to register custom resource definitions..."

crd_servicemonitors_status="false"
until [ "$crd_servicemonitors_status" = "True" ]; do sleep 1; printf "."; crd_servicemonitors_status=`kctl get customresourcedefinitions servicemonitors.monitoring.coreos.com -o jsonpath='{.status.conditions[1].status}' 2>&1`; done

crd_prometheuses_status="false"
until [ "$crd_prometheuses_status" = "True" ]; do sleep 1; printf "."; crd_prometheuses_status=`kctl get customresourcedefinitions prometheuses.monitoring.coreos.com -o jsonpath='{.status.conditions[1].status}' 2>&1`; done

crd_alertmanagers_status="false"
until [ "$crd_alertmanagers_status" = "True" ]; do sleep 1; printf "."; crd_alertmanagers_status=`kctl get customresourcedefinitions alertmanagers.monitoring.coreos.com -o jsonpath='{.status.conditions[1].status}' 2>&1`; done

until kctl get servicemonitors.monitoring.coreos.com > /dev/null 2>&1; do sleep 1; printf "."; done
until kctl get prometheuses.monitoring.coreos.com > /dev/null 2>&1; do sleep 1; printf "."; done
until kctl get alertmanagers.monitoring.coreos.com > /dev/null 2>&1; do sleep 1; printf "."; done

echo 'Phase1 done!'

kubectl apply -f manifests/phase2

echo 'Phase2 done!'

kubectl apply -f /var/tmp/wise2c/prometheus/prometheus-service.yaml
kubectl apply -f /var/tmp/wise2c/prometheus/alertmanager-service.yaml
kubectl apply -f /var/tmp/wise2c/prometheus/grafana-service.yaml

echo 'NodePorts are set for services.'
