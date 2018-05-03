FROM busybox:latest

WORKDIR /workspace

COPY callback_plugins /workspace/callback_plugins
COPY docker-playbook /workspace/docker-playbook
COPY etcd-playbook /workspace/etcd-playbook
COPY kubernetes-playbook /workspace/kubernetes-playbook
COPY registry-playbook /workspace/registry-playbook
COPY components_order.conf /workspace