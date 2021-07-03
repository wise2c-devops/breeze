#!/bin/bash
cd /etc/kubernetes/

kubectl config set-credentials kubernetes-admin --client-certificate=/etc/kubernetes/pki/admin.pem  --client-key=/etc/kubernetes/pki/admin-key.pem  --embed-certs=true --kubeconfig=admin.conf

kubectl config set-credentials system:kube-controller-manager --client-certificate=/etc/kubernetes/pki/controller-manager.pem  --client-key=/etc/kubernetes/pki/controller-manager-key.pem  --embed-certs=true --kubeconfig=controller-manager.conf

kubectl config set-credentials system:kube-scheduler --client-certificate=/etc/kubernetes/pki/scheduler.pem  --client-key=/etc/kubernetes/pki/scheduler-key.pem  --embed-certs=true --kubeconfig=scheduler.conf

#restart controller-manager and scheduler
#podman ps|grep kube-controller-manager|awk '{print $1}'|xargs podman stop
#podman ps|grep kube-scheduler|awk '{print $1}'|xargs podman stop
