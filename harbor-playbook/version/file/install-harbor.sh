#!/bin/bash
sed -i '0,/https:/s//# https:/' harbor.yml
sed -i 's,port: 443,# port: 443,g' harbor.yml
sed -i 's,certificate:,# certificate:,g' harbor.yml
sed -i 's,private_key:,# private_key:,g' harbor.yml

#set +e
#docker network create harbor_harbor
#set -e

./install.sh

# How to add Harbor as Helm Charts repo?
# helm repo add --username={{ registry_user }} --password={{ registry_password }} {{ registry_project }} http://{{ registry_endpoint }}/chartrepo/{{ registry_project }}
# Starting from Harbor version 2.8, the helm repo add command is not supported. Each pull needs to specify the complete access path.

# How to login Harbor Helm Charts repo?
#helm registry login http://{{ registry_endpoint }} --insecure--username {{ registry_user }} --password {{ registry_password }}

# How to push charts package to Harbor?
#helm push --insecure-skip-tls-verify hello-0.1.0.tgz oci://{{ registry_endpoint }}/library

# How to pull charts package from Harbor?
#helm pull --insecure-skip-tls-verify oci://{{ registry_endpoint }}/library/hello
