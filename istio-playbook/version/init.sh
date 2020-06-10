#! /bin/bash

set -e

path=`dirname $0`

IstioVersion=`cat ${path}/components-version.txt |grep "Istio" |awk '{print $3}'`

echo "" >> ${path}/group_vars/istio.yml
echo "istio_version: ${IstioVersion}" >> ${path}/group_vars/istio.yml

curl -L -o ${path}/file/istio-$IstioVersion-origin.tar.gz https://github.com/istio/istio/releases/download/$IstioVersion/istio-$IstioVersion-linux-amd64.tar.gz

cd ${path}/file/
tar zxf istio-$IstioVersion-origin.tar.gz
echo "istio/proxyv2:$IstioVersion" > images-list.txt
echo "istio/pilot:$IstioVersion" >> images-list.txt
echo "istio/mixer:$IstioVersion" >> images-list.txt
echo "istio/operator:$IstioVersion" >> images-list.txt

cat istio-$IstioVersion/samples/addons/kiali.yaml |grep image |awk -F ":" '{print $2":"$3}' |grep -v IfNotPresent >> images-list.txt
cat istio-$IstioVersion/samples/addons/jaeger.yaml |grep image |awk -F "[\"]" '{print $2}' |awk -F "/" '{print $2"/"$3}' >> images-list.txt
cat istio-$IstioVersion/samples/addons/extras/zipkin.yaml |grep image |awk -F':' '{print $2":"$3}' >> images-list.txt
cat istio-$IstioVersion/samples/addons/prometheus.yaml |grep "image:" |awk -F':' '{print $2":"$3}' |awk -F "[\"]" '{print $2}' >> images-list.txt
cat istio-$IstioVersion/samples/addons/grafana.yaml |grep image |awk -F "[\"]" '{print $2}' >> images-list.txt

#echo "ubuntu:bionic" >> images-list.txt

echo 'Images list for Istio:'
cat images-list.txt

for file in $(cat images-list.txt); do docker pull $file; done
echo 'Images pulled.'

docker save $(cat images-list.txt) -o istio-images-$IstioVersion.tar
echo 'Images saved.'
bzip2 -z --best istio-images-$IstioVersion.tar
echo 'Images are compressed as bzip format.'

rm -rf istio-$IstioVersion
