#!/bin/bash
sed -i '0,/https:/s//# https:/' harbor.yml
sed -i 's,port: 443,# port: 443,g' harbor.yml
sed -i 's,certificate:,# certificate:,g' harbor.yml
sed -i 's,private_key:,# private_key:,g' harbor.yml

./install.sh --with-clair --with-chartmuseum
