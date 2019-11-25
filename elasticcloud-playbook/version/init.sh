#! /bin/bash

set -e

path=`dirname $0`

ElasticCloudVersion=`cat ${path}/components-version.txt |grep "ElasticCloud" |awk '{print $3}'`
ElasticStackVersion=`cat ${path}/components-version.txt |grep "ElasticCloud" |awk '{print $3}'`
echo $ElasticCloudVersion
echo $ElasticStackVersion

echo "" >> ${path}/group_vars/elasticcloud.yml
echo "elastic_cloud_version: ${ElasticCloudVersion}" >> ${path}/group_vars/elasticcloud.yml
echo "elastic_stack_version: ${ElasticStackVersion}" >> ${path}/group_vars/elasticcloud.yml

curl -L -o ${path}/file/eck.yaml https://download.elastic.co/downloads/eck/${ElasticCloudVersion}/all-in-one.yaml

cat ${path}/file/eck.yaml |grep "image: docker.elastic.co/eck/" |awk -F":" '{print $2":"$3}' > images-list.txt
echo 'docker.elastic.co/elasticsearch/elasticsearch:${ElasticStackVersion}' >> images-list.txt
echo 'docker.elastic.co/kibana/kibana:${ElasticStackVersion}' >> images-list.txt

echo 'Images list for Elastic Cloud:'
cat images-list.txt

for file in $(cat images-list.txt); do docker pull $file; done
echo 'Images pulled.'

docker save $(cat images-list.txt) -o elastic-cloud-images.tar
echo 'Images saved.'
bzip2 -z --best elastic-cloud-images.tar
echo 'Images are compressed as bzip format.'
