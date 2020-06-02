#! /bin/bash

set -e

path=`dirname $0`

k8s_version=`cat ${path}/components-version.txt |grep "Kubernetes" |awk '{print $3}'`

docker run --rm --name=kubeadm-version wise2c/kubeadm-version:v${k8s_version} kubeadm config images list --kubernetes-version ${k8s_version} > ${path}/k8s-images-list.txt

echo "=== pulling kubernetes images ==="
for IMAGES in $(cat ${path}/k8s-images-list.txt |grep -v etcd); do
  docker pull ${IMAGES}
done
echo "=== kubernetes images are pulled successfully ==="

echo "=== saving kubernetes images ==="
mkdir -p ${path}/file
docker save $(cat ${path}/k8s-images-list.txt |grep -v etcd) -o ${path}/file/k8s.tar
rm ${path}/file/k8s.tar.bz2 -f
bzip2 -z --best ${path}/file/k8s.tar
echo "=== kubernetes images are saved successfully ==="

kubernetes_repo=`cat ${path}/k8s-images-list.txt |grep kube-apiserver |awk -F '/' '{print $1}'`
kubernetes_version=`cat ${path}/k8s-images-list.txt |grep kube-apiserver |awk -F ':' '{print $2}'`
dns_version=`cat ${path}/k8s-images-list.txt |grep coredns |awk -F ':' '{print $2}'`
pause_version=`cat ${path}/k8s-images-list.txt |grep pause |awk -F ':' '{print $2}'`

echo "" >> ${path}/inherent.yaml
echo "version: ${kubernetes_version}" >> ${path}/inherent.yaml

echo "" >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_repo: ${kubernetes_repo}" >> ${path}/yat/all.yml.gotmpl
echo "kubernetes_version: ${kubernetes_version}" >> ${path}/yat/all.yml.gotmpl
echo "dns_version: ${dns_version}" >> ${path}/yat/all.yml.gotmpl
echo "pause_version: ${pause_version}" >> ${path}/yat/all.yml.gotmpl

flannel_repo="quay.io/coreos"
flannel_version=v`cat ${path}/components-version.txt |grep "Flannel" |awk '{print $3}'`

echo "flannel_repo: ${flannel_repo}" >> ${path}/yat/all.yml.gotmpl
echo "flannel_version: ${flannel_version}-amd64" >> ${path}/yat/all.yml.gotmpl
echo "flannel_version_short: ${flannel_version}" >> ${path}/yat/all.yml.gotmpl

curl -sSL https://raw.githubusercontent.com/coreos/flannel/${flannel_version}/Documentation/kube-flannel.yml \
   | sed -e "s,quay.io/coreos,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/kube-flannel.yml.j2

echo "=== pulling flannel image ==="
docker pull ${flannel_repo}/flannel:${flannel_version}-amd64
echo "=== flannel image is pulled successfully ==="

echo "=== saving flannel image ==="
docker save ${flannel_repo}/flannel:${flannel_version}-amd64 \
    > ${path}/file/flannel.tar
rm ${path}/file/flannel.tar.bz2 -f
bzip2 -z --best ${path}/file/flannel.tar
echo "=== flannel image is saved successfully ==="

calico_version=v`cat ${path}/components-version.txt |grep "Calico" |awk '{print $3}'`
echo "calico_version: ${calico_version}" >> ${path}/yat/all.yml.gotmpl
echo "=== downloading calico release package ==="
curl -L -o ${path}/file/calico-${calico_version}.tgz https://github.com/projectcalico/calico/releases/download/${calico_version}/release-${calico_version}.tgz
echo "=== calico release package is downloaded successfully ==="
tar zxf ${path}/file/calico-${calico_version}.tgz -C ${path}/file/
rm -f ${path}/file/calico-${calico_version}.tgz
mv ${path}/file/release-${calico_version} ${path}/file/calico
rm -rf ${path}/file/calico/bin
docker pull calico/pod2daemon-flexvol:${calico_version}
docker save calico/pod2daemon-flexvol:${calico_version} -o ${path}/file/calico/images/calico-pod2daemon-flexvol.tar
docker pull calico/ctl:${calico_version}
docker save calico/ctl:${calico_version} -o ${path}/file/calico/images/calico-ctl.tar
echo "=== Compressing calico images ==="
bzip2 -z --best ${path}/file/calico/images/calico-cni.tar
bzip2 -z --best ${path}/file/calico/images/calico-kube-controllers.tar
bzip2 -z --best ${path}/file/calico/images/calico-node.tar
bzip2 -z --best ${path}/file/calico/images/calico-pod2daemon-flexvol.tar
bzip2 -z --best ${path}/file/calico/images/calico-typha.tar
bzip2 -z --best ${path}/file/calico/images/calico-ctl.tar
echo "=== Calico images are compressed as bzip format successfully ==="

dashboard_repo=kubernetesui
dashboard_version=v`cat ${path}/components-version.txt |grep "Dashboard" |awk '{print $3}'`
metrics_scraper_version=v`cat ${path}/components-version.txt |grep "MetricsScraper" |awk '{print $3}'`

echo "dashboard_repo: ${dashboard_repo}" >> ${path}/yat/all.yml.gotmpl
echo "dashboard_version: ${dashboard_version}" >> ${path}/yat/all.yml.gotmpl
echo "metrics_scraper_version: ${metrics_scraper_version}" >> ${path}/yat/all.yml.gotmpl

metrics_server_repo=${kubernetes_repo}
metrics_server_version=v`cat ${path}/components-version.txt |grep "MetricsServer" |awk '{print $3}'`

echo "metrics_server_repo: ${metrics_server_repo}" >> ${path}/yat/all.yml.gotmpl
echo "metrics_server_version: ${metrics_server_version}" >> ${path}/yat/all.yml.gotmpl

curl -sS https://raw.githubusercontent.com/kubernetes/dashboard/${dashboard_version}/aio/deploy/recommended.yaml \
    | sed -e "s,kubernetesui,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/kubernetes-dashboard.yml.j2

echo "=== pulling kubernetes dashboard and metrics-server images ==="
docker pull ${dashboard_repo}/dashboard:${dashboard_version}
docker pull ${dashboard_repo}/metrics-scraper:${metrics_scraper_version}
docker pull ${metrics_server_repo}/metrics-server-amd64:${metrics_server_version}
echo "=== kubernetes dashboard and metrics-server images are pulled successfully ==="

echo "=== saving kubernetes dashboard images ==="
docker save ${dashboard_repo}/dashboard:${dashboard_version} -o ${path}/file/dashboard.tar
docker save ${dashboard_repo}/metrics-scraper:${metrics_scraper_version} -o ${path}/file/metrics-scraper.tar
docker save ${metrics_server_repo}/metrics-server-amd64:${metrics_server_version} -o ${path}/file/metrics-server.tar
rm -f ${path}/file/dashboard.tar.bz2
rm -f ${path}/file/metrics-scraper.tar.bz2
rm -f ${path}/file/metrics-server.tar.bz2
bzip2 -z --best ${path}/file/dashboard.tar
bzip2 -z --best ${path}/file/metrics-scraper.tar
bzip2 -z --best ${path}/file/metrics-server.tar

echo "=== kubernetes dashboard and metrics-server images are saved successfully ==="

contour_repo="projectcontour"
contour_long_repo="docker.io/projectcontour"
contour_envoyproxy_repo="envoyproxy"
contour_envoyproxy_long_repo="docker.io/envoyproxy"
contour_demo_repo="gcr.io/kuar-demo"
contour_version=v`cat ${path}/components-version.txt |grep "Contour Version" |awk '{print $3}'`
contour_envoyproxy_version=v`cat ${path}/components-version.txt |grep "ContourEnvoyProxy Version" |awk '{print $3}'`

echo "contour_repo: ${contour_repo}" >> ${path}/yat/all.yml.gotmpl
echo "contour_long_repo: ${contour_long_repo}" >> ${path}/yat/all.yml.gotmpl
echo "contour_envoyproxy_repo: ${contour_envoyproxy_repo}" >> ${path}/yat/all.yml.gotmpl
echo "contour_envoyproxy_long_repo: ${contour_envoyproxy_long_repo}" >> ${path}/yat/all.yml.gotmpl
echo "contour_demo_repo: ${contour_demo_repo}" >> ${path}/yat/all.yml.gotmpl
echo "contour_version: ${contour_version}" >> ${path}/yat/all.yml.gotmpl
echo "contour_envoyproxy_version: ${contour_envoyproxy_version}" >> ${path}/yat/all.yml.gotmpl

curl -sS https://raw.githubusercontent.com/projectcontour/contour/${contour_version}/examples/render/contour.yaml \
    | sed -e "s#image: docker.io/projectcontour/contour:latest#image: docker.io/projectcontour/contour:${contour_version}#g" > ${path}/template/contour.yml.j2
sed -i "s,docker.io/projectcontour,{{ registry_endpoint }}/{{ registry_project }},g" ${path}/template/contour.yml.j2
sed -i "s,docker.io/envoyproxy,{{ registry_endpoint }}/{{ registry_project }},g" ${path}/template/contour.yml.j2

curl -sS https://projectcontour.io/examples/kuard.yaml \
    | sed -e "s,gcr.io/kuar-demo,{{ registry_endpoint }}/{{ registry_project }},g" > ${path}/template/contour-demo.yml.j2

echo "=== pulling contour and envoyproxy images ==="
docker pull ${contour_repo}/contour:${contour_version}
docker pull ${contour_envoyproxy_repo}/envoy:${contour_envoyproxy_version}
docker pull ${contour_demo_repo}/kuard-amd64:1
echo "=== contour and envoyproxy images are pulled successfully ==="

echo "=== saving contour and envoyproxy images ==="
docker save ${contour_repo}/contour:${contour_version} -o ${path}/file/contour.tar
docker save ${contour_envoyproxy_repo}/envoy:${contour_envoyproxy_version} -o ${path}/file/contour-envoyproxy.tar
docker save ${contour_demo_repo}/kuard-amd64:1 -o ${path}/file/contour-demo.tar
rm -f ${path}/file/contour.tar.bz2
rm -f ${path}/file/contour-envoyproxy.tar.bz2
rm -f ${path}/file/contour-demo.tar.bz2
bzip2 -z --best ${path}/file/contour.tar
bzip2 -z --best ${path}/file/contour-envoyproxy.tar
bzip2 -z --best ${path}/file/contour-demo.tar

echo "=== contour and envoyproxy images are saved successfully ==="

echo "=== download cfssl tools ==="
export CFSSL_URL=https://pkg.cfssl.org/R1.2
curl -L -o cfssl ${CFSSL_URL}/cfssl_linux-amd64
curl -L -o cfssljson ${CFSSL_URL}/cfssljson_linux-amd64
curl -L -o cfssl-certinfo ${CFSSL_URL}/cfssl-certinfo_linux-amd64
chmod +x cfssl cfssljson cfssl-certinfo
tar zcvf ${path}/file/cfssl-tools.tar.gz cfssl cfssl-certinfo cfssljson
echo "=== cfssl tools is download successfully ==="

helm_version=v`cat ${path}/components-version.txt |grep "Helm" |awk '{print $3}'`

echo "=== download helm binary package ==="
rm ${path}/file/helm-linux-amd64.tar.gz -f
curl -o ${path}/file/helm-linux-amd64.tar.gz https://get.helm.sh/helm-${helm_version}-linux-amd64.tar.gz
echo "=== helm binary package is saved successfully ==="
