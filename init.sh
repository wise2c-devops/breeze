#! /bin/bash

set -e

path=`dirname $0`

kubernetes_version=1.13.1
harbor_version=1.7.0
docker_version=18.06.1
haproxy_version=1.8.14
keepalived_version=1.3.5
loadbalancer_version=HAProxy-${haproxy_version}_Keepalived-${keepalived_version}

mv ${path}/kubernetes-playbook/version ${path}/kubernetes-playbook/v${kubernetes_version}
mv ${path}/harbor-playbook/version ${path}/harbor-playbook/v${harbor_version}
mv ${path}/docker-playbook/version ${path}/docker-playbook/${docker_version}-ce
mv ${path}/loadbalancer-playbook/version ${path}/loadbalancer-playbook/${loadbalancer_version}

docker run --rm --name=kubeadm-version wise2c/kubeadm-version:$TRAVIS_BRANCH kubeadm config images list --kubernetes-version ${kubernetes_version} > ${path}/k8s-images-list.txt

etcd_version=`cat ${path}/k8s-images-list.txt |grep etcd |awk -F ':' '{print $2}'`
mv etcd-playbook/version-by-kubeadm etcd-playbook/${etcd_version}

echo "Kubernetes Version: ${kubernetes_version}" > ${path}/components-version.txt
echo "Harbor Version: ${harbor_version}" >> ${path}/components-version.txt
echo "Docker Version: ${docker_version}" >> ${path}/components-version.txt
echo "HAProxy Version: ${haproxy_version}" >> ${path}/components-version.txt
echo "Keepalived Version: ${keepalived_version}" >> ${path}/components-version.txt

for dir in `ls ${path}`
do
    if [[ ${dir} =~ -playbook$ ]]; then
        for version in `ls ${path}/${dir}`
        do
            cp ${path}/components-version.txt ${path}/${dir}/${version}/
            echo ${version}
            if [ -f ${path}/${dir}/${version}/init.sh ]; then
                bash ${path}/${dir}/${version}/init.sh ${version}
            fi
        done
    fi
done
