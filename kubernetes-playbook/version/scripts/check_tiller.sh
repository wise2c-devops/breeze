#!/bin/bash
tiller_status="false"
until [ "$tiller_status" = "Running" ]; do sleep 1; printf "."; tiller_status=`kubectl -n kube-system get pods $(kubectl -n kube-system get pods |grep tiller-deploy |awk '{print $1}') -o jsonpath='{.status.phase}' 2>&1`; done
