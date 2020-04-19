#! /bin/bash

set -e

path=`dirname $0`

KubePrometheusVersion=`cat ${path}/components-version.txt |grep "KubePrometheus" |awk '{print $3}'`
PrometheusOperatorVersion=`cat ${path}/components-version.txt |grep "PrometheusOperator" |awk '{print $3}'`

echo "" >> ${path}/group_vars/prometheus.yml.gotmpl
echo "kube_prometheus_version: ${KubePrometheusVersion}" >> ${path}/group_vars/prometheus.yml
echo "operator_version: ${PrometheusOperatorVersion}" >> ${path}/group_vars/prometheus.yml

curl -L -o ${path}/file/kube-prometheus-v$KubePrometheusVersion-origin.tar.gz https://github.com/coreos/kube-prometheus/archive/v$KubePrometheusVersion.tar.gz

cd ${path}/file/
tar zxf kube-prometheus-v$KubePrometheusVersion-origin.tar.gz

for file in $(grep -lr "quay.io/coreos" kube-prometheus-$KubePrometheusVersion/manifests/); do cat $file |grep "quay.io/coreos" ; done > image-lists-temp.txt
for file in $(grep -lr "grafana/grafana" kube-prometheus-$KubePrometheusVersion/manifests/); do cat $file |grep "grafana/grafana" ; done >> image-lists-temp.txt
for file in $(grep -lr "quay.io/prometheus" kube-prometheus-$KubePrometheusVersion/manifests/); do cat $file |grep "quay.io/prometheus" ; done >> image-lists-temp.txt
for file in $(grep -lr "gcr.io/" kube-prometheus-$KubePrometheusVersion/manifests/); do cat $file |grep "gcr.io/" ; done >> image-lists-temp.txt

prometheus_base_image=`cat kube-prometheus-$KubePrometheusVersion/manifests/prometheus-prometheus.yaml |grep "image: " |awk -F':' '{print $2}'`
prometheus_image_tag=`cat kube-prometheus-$KubePrometheusVersion/manifests/prometheus-prometheus.yaml |grep "image " |awk -F':' '{print $3}'`

alertmanager_base_image=`cat kube-prometheus-$KubePrometheusVersion/manifests/alertmanager-alertmanager.yaml |grep "image: " |awk -F':' '{print $2}'`
alertmanager_image_tag=`cat kube-prometheus-$KubePrometheusVersion/manifests/alertmanager-alertmanager.yaml |grep "image: " |awk -F':' '{print $3}'`

echo $prometheus_base_image:$prometheus_image_tag >> image-lists-temp.txt
echo $alertmanager_base_image:$alertmanager_image_tag >> image-lists-temp.txt

rm -rf kube-prometheus-$KubePrometheusVersion

sed "s/- --config-reloader-image=//g" image-lists-temp.txt > 1.txt
sed "s/- --prometheus-config-reloader=//g" 1.txt > 2.txt
sed "s/image: //g" 2.txt > 3.txt
rm -f image-lists-temp.txt 1.txt 2.txt
mv 3.txt images-list.txt

cat images-list.txt

for file in $(cat images-list.txt); do docker pull $file; done
echo 'Images pulled.'

docker save $(cat images-list.txt) -o kube-prometheus-images-v$KubePrometheusVersion.tar
echo 'Images saved.'
bzip2 -z --best kube-prometheus-images-v$KubePrometheusVersion.tar
echo 'Images are compressed as bzip format.'
