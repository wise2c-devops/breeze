#! /bin/bash

set -e

path=`dirname $0`

docker run --rm --name=kubeadm-version wise2ck8s/kubeadm-version:$TRAVIS_BRANCH kubeadm config images list > ${path}/k8s-images-list.txt

etcd_version=`cat ${path}/k8s-images-list.txt |grep etcd |awk -F ':' '{print $2}'`
mv etcd-playbook/version-by-kubeadm etcd-playbook/${etcd_version}

for dir in `ls ${path}`
do
    if [[ ${dir} =~ -playbook$ ]]; then
        for version in `ls ${path}/${dir}`
        do
            echo ${version}
            if [ -f ${path}/${dir}/${version}/init.sh ]; then
                bash ${path}/${dir}/${version}/init.sh ${version}
            fi
        done
    fi
done
