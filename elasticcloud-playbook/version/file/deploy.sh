#!/bin/bash
set -e
cd /var/lib/wise2c/tmp/elasticcloud

# Elastic Operator deploy
kubectl create -f  ./eck.yml

# Wait for CRDs to be ready.
printf "Waiting for ElasticCloud Operator to register custom resource definitions..."

crd_apmservers_status="false"
until [ "$crd_apmservers_status" = "True" ]; do sleep 1; printf "."; crd_apmservers_status=`kubectl get customresourcedefinitions apmservers.apm.k8s.elastic.co -o jsonpath='{.status.conditions[1].status}' 2>&1`; done

crd_elasticsearches_status="false"
until [ "$crd_elasticsearches_status" = "True" ]; do sleep 1; printf "."; crd_elasticsearches_status=`kubectl get customresourcedefinitions elasticsearches.elasticsearch.k8s.elastic.co -o jsonpath='{.status.conditions[1].status}' 2>&1`; done

crd_kibanas_status="false"
until [ "$crd_kibanas_status" = "True" ]; do sleep 1; printf "."; crd_kibanas_status=`kubectl get customresourcedefinitions kibanas.kibana.k8s.elastic.co -o jsonpath='{.status.conditions[1].status}' 2>&1`; done

until kubectl get apmservers.apm.k8s.elastic.co > /dev/null 2>&1; do sleep 1; printf "."; done
until kubectl get elasticsearches.elasticsearch.k8s.elastic.co > /dev/null 2>&1; do sleep 1; printf "."; done
until kubectl get kibanas.kibana.k8s.elastic.co > /dev/null 2>&1; do sleep 1; printf "."; done

echo 'Elastic Cloud CRD is ready!'

kubectl apply -f elasticsearch.yml
kubectl apply -f kibana.yml
kubectl apply -f elasticsearch-service.yml
kubectl apply -f kibana-service.yml

echo 'Elastic Cloud has been deployed.'

# Deploy Fluentd
set +e
estatus="false"
until [ "$estatus" = "Secret" ]; do sleep 1; printf "."; estatus=`kubectl get secret quickstart-es-elastic-user -o jsonpath='{.kind}'`; done
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode)
sed -i "s,changeme,${PASSWORD},g" fluentd.yml
#kubectl apply -f fluentd.yml
# https://github.com/fluent/fluent-plugin-parser-cri
# cri log parser is not implemented
