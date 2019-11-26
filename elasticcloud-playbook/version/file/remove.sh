#!/bin/bash
kubectl delete -f /var/tmp/wise2c/elasticcloud/fluentd.yml
kubectl delete -f /var/tmp/wise2c/elasticcloud/kibana-service.yml
kubectl delete -f /var/tmp/wise2c/elasticcloud/elasticsearch-service.yml
kubectl delete kibana quickstart
kubectl delete elasticsearch quickstart
kubectl delete -f /var/tmp/wise2c/elasticcloud/kibana.yml
kubectl delete -f /var/tmp/wise2c/elasticcloud/elasticsearch.yml
kubectl delete -f /var/tmp/wise2c/elasticcloud/eck.yml
