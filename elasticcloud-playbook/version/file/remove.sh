#!/bin/bash
kubectl delete -f /var/lib/wise2c/tmp/elasticcloud/filebeat.yml
kubectl delete -f /var/lib/wise2c/tmp/elasticcloud/kibana-service.yml
kubectl delete -f /var/lib/wise2c/tmp/elasticcloud/elasticsearch-service.yml
kubectl delete kibana quickstart
kubectl delete elasticsearch quickstart
kubectl delete -f /var/lib/wise2c/tmp/elasticcloud/kibana.yml
kubectl delete -f /var/lib/wise2c/tmp/elasticcloud/elasticsearch.yml
kubectl delete -f /var/lib/wise2c/tmp/elasticcloud/eck.yml
kubectl delete -f /var/lib/wise2c/tmp/elasticcloud/crds.yml
