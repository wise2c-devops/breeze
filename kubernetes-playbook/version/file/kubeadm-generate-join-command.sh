#!/bin/bash
kubeadm token create --print-join-command > /var/tmp/wise2c/kubernetes/worker-join-command.sh
chmod +x /var/tmp/wise2c/kubernetes/worker-join-command.sh
