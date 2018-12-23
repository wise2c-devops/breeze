FROM busybox:latest

WORKDIR /workspace

COPY callback_plugins /workspace/callback_plugins
COPY docker-playbook /workspace/docker-playbook
COPY etcd-playbook /workspace/etcd-playbook
COPY kubernetes-playbook /workspace/kubernetes-playbook
COPY harbor-playbook /workspace/harbor-playbook
copy loadbalancer-playbook /workspace/loadbalancer-playbook
copy prometheus-playbook /workspace/prometheus-playbook
COPY components_order.conf /workspace
