#! /bin/bash

set -e

#path=`dirname $0`
path=/builds/$CI_PROJECT_PATH

ElasticCloudVersion=`cat ${path}/components-version.txt |grep "ElasticCloud" |awk '{print $3}'`
ElasticStackVersion=`cat ${path}/components-version.txt |grep "ElasticStack" |awk '{print $3}'`

echo "" >> ${path}/group_vars/elasticcloud.yml
echo "elastic_cloud_version: ${ElasticCloudVersion}" >> ${path}/group_vars/elasticcloud.yml
echo "elastic_stack_version: ${ElasticStackVersion}" >> ${path}/group_vars/elasticcloud.yml

curl -L -o ${path}/template/eck.yml.j2 https://download.elastic.co/downloads/eck/${ElasticCloudVersion}/all-in-one.yaml

cat ${path}/template/eck.yml.j2 |grep 'image: "docker.elastic.co/eck/' |awk -F":" '{print $2":"$3}' |awk -F'"' '{print $2}' > images-list.txt
echo "docker.elastic.co/elasticsearch/elasticsearch:${ElasticStackVersion}" >> images-list.txt
echo "docker.elastic.co/kibana/kibana:${ElasticStackVersion}" >> images-list.txt
echo "fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch" >> images-list.txt

echo 'Images list for Elastic Cloud:'
cat images-list.txt

for file in $(cat images-list.txt); do docker pull $file; done
echo 'Images pulled.'

docker save $(cat images-list.txt) -o ${path}/file/elastic-cloud-images.tar
echo 'Images saved.'
bzip2 -z --best ${path}/file/elastic-cloud-images.tar
echo 'Images are compressed as bzip format.'

sed -i "s,docker.elastic.co/eck,{{ registry_endpoint }}/{{ registry_project }},g" ${path}/template/eck.yml.j2

curl -L -o ${path}/template/fluentd.yml.j2 https://raw.githubusercontent.com/fluent/fluentd-kubernetes-daemonset/master/fluentd-daemonset-elasticsearch-rbac.yaml
sed -i "s,fluent/fluentd-kubernetes-daemonset,{{ registry_endpoint }}/{{ registry_project }}/fluentd-kubernetes-daemonset,g" ${path}/template/fluentd.yml.j2
sed -i "s,elasticsearch-logging,quickstart-es-http.default.svc.cluster.local,g" ${path}/template/fluentd.yml.j2
