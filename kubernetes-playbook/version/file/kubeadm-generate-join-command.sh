#!/bin/bash
kubeadm token create --print-join-command > /var/lib/wise2c/tmp/kubernetes/worker-join-command.sh
chmod +x /var/lib/wise2c/tmp/kubernetes/worker-join-command.sh
