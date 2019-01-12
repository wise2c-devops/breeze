#!/bin/bash
kubeadm_token=`kubeadm token generate`
sed -i "s/wise2c-breeze-token/${kubeadm_token}/g" ./kubeadm.conf
