#! /bin/bash

set -e

path=`dirname $0`

kubernetes_version=1.24.15
harbor_version=2.7.2
docker_version=23.0.1
crio_version=1.24.5
haproxy_version=2.0.0
keepalived_version=1.3.5
loadbalancer_version=HAProxy-${haproxy_version}_Keepalived-${keepalived_version}
prometheus_version=2.41.0
prometheus_operator_version=0.62.0
kube_prometheus_version=0.12.0
metrics_server_version=0.6.3
dashboard_version=2.6.1
metrics_scraper_version=1.0.8
flannel_version=0.21.5
flannel_cni_plugin_version=1.1.2
calico_version=3.25.1
helm_version=3.12.0
istio_version=1.17.2
contour_version=1.25.0
contour_envoyproxy_version=1.26.1
elastic_cloud_version=2.7.0
elastic_stack_version=8.7.1

mv ${path}/kubernetes-playbook/version ${path}/kubernetes-playbook/v${kubernetes_version}
mv ${path}/harbor-playbook/version ${path}/harbor-playbook/v${harbor_version}
mv ${path}/docker-playbook/version ${path}/docker-playbook/${docker_version}-CE
mv ${path}/crio-playbook/version ${path}/crio-playbook/${crio_version}
mv ${path}/loadbalancer-playbook/version ${path}/loadbalancer-playbook/${loadbalancer_version}
mv ${path}/prometheus-playbook/version ${path}/prometheus-playbook/Kube-Prometheus-v${kube_prometheus_version}
mv ${path}/istio-playbook/version ${path}/istio-playbook/v${istio_version}
mv ${path}/elasticcloud-playbook/version ${path}/elasticcloud-playbook/v${elastic_cloud_version}

docker run --rm --name=kubeadm-version wise2c/kubeadm-version:v${kubernetes_version} kubeadm config images list --kubernetes-version ${kubernetes_version} > ${path}/k8s-images-list.txt

etcd_version=`cat ${path}/k8s-images-list.txt |grep etcd |awk -F ':' '{print $2}'`
mv etcd-playbook/version-by-kubeadm etcd-playbook/${etcd_version}

echo "ETCD Version: ${etcd_version}" > ${path}/components-version.txt
echo "Kubernetes Version: ${kubernetes_version}" >> ${path}/components-version.txt
echo "Harbor Version: ${harbor_version}" >> ${path}/components-version.txt
echo "Docker Version: ${docker_version}" >> ${path}/components-version.txt
echo "CRIO Version: ${crio_version}" >> ${path}/components-version.txt
echo "HAProxy Version: ${haproxy_version}" >> ${path}/components-version.txt
echo "Keepalived Version: ${keepalived_version}" >> ${path}/components-version.txt
echo "Prometheus Version: ${prometheus_version}" >> ${path}/components-version.txt
echo "PrometheusOperator Version: ${prometheus_operator_version}" >> ${path}/components-version.txt
echo "KubePrometheus Version: ${kube_prometheus_version}" >> ${path}/components-version.txt
echo "MetricsServer Version: ${metrics_server_version}" >> ${path}/components-version.txt
echo "Dashboard Version: ${dashboard_version}" >> ${path}/components-version.txt
echo "MetricsScraper Version: ${metrics_scraper_version}" >> ${path}/components-version.txt
echo "Flannel Version: ${flannel_version}" >> ${path}/components-version.txt
echo "flannel-cni-plugin Version: ${flannel_cni_plugin_version}" >> ${path}/components-version.txt
echo "Calico Version: ${calico_version}" >> ${path}/components-version.txt
echo "Helm Version: ${helm_version}" >> ${path}/components-version.txt
echo "Istio Version: ${istio_version}" >> ${path}/components-version.txt
echo "Contour Version: ${contour_version}" >> ${path}/components-version.txt
echo "ContourEnvoyProxy Version: ${contour_envoyproxy_version}" >> ${path}/components-version.txt
echo "ElasticCloud Version: ${elastic_cloud_version}" >> ${path}/components-version.txt
echo "ElasticStack Version: ${elastic_stack_version}" >> ${path}/components-version.txt

for dir in `ls ${path}`
do
    if [[ ${dir} =~ -playbook$ ]]; then
        chmod -R 775 ${dir}
        for version in `ls ${path}/${dir}`
        do
            echo ${version}
            if [ -f ${path}/${dir}/${version}/init.sh ]; then
                cp ${path}/components-version.txt ${path}/${dir}/${version}/
                bash ${path}/${dir}/${version}/init.sh ${version}
            fi
        done
    fi
done
