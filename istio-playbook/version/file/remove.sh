#!/bin/bash
helm delete istio

helm delete istio-init

kubectl delete clusterrole istio-citadel-istio-system istio-galley-istio-system istio-grafana-post-install-istio-system istio-init-istio-system istio-mixer-istio-system istio-pilot-istio-system istio-reader istio-security-post-install-istio-system  istio-sidecar-injector-istio-system  prometheus-istio-system kiali kiali-viewer

kubectl delete clusterrolebindings istio-citadel-istio-system istio-galley-admin-role-binding-istio-system istio-grafana-post-install-role-binding-istio-system istio-init-admin-role-binding-istio-system istio-kiali-admin-role-binding-istio-system istio-mixer-admin-role-binding-istio-system istio-multi istio-pilot-istio-system  istio-security-post-install-role-binding-istio-system istio-sidecar-injector-admin-role-binding-istio-system prometheus-istio-system

kubectl delete MutatingWebhookConfiguration/istio-sidecar-injector

kubectl delete -f /var/tmp/wise2c/istio/istio-*/install/kubernetes/helm/istio-init/files

kubectl delete ns istio-system
