#! /bin/bash

# while read -r line
# do 
#   if [[ "${line}" =~ "server: https://$1:$2" ]]
#     then printf ${line}
#   fi
# done < /etc/kubernetes/kubelet.conf

code=`curl -sL -o /dev/null -w %{response_code} http://127.0.0.1:10255/stats`
if [ "${code}" == "200" ]; then
printf true
else
printf false
fi