#! /bin/bash
kubelet_code_stats=`curl -sLk -o /dev/null -w %{response_code} https://127.0.0.1:10255/stats`
kubelet_code_errortest=`curl -sLk -o /dev/null -w %{response_code} https://127.0.0.1:10255/errortest`
kubeproxy_code_healthz=`curl -sLk -o /dev/null -w %{response_code} http://127.0.0.1:10256/healthz`
kubeproxy_code_errortest=`curl -sLk -o /dev/null -w %{response_code} http://127.0.0.1:10256/errortest`

if ( [ "$kubelet_code_stats" == "200" ] || [ "$kubelet_code_stats" == "401" ] ) && [ "$kubelet_code_errortest" == "404" ]; then
  kubelet_health=true
else
  kubelet_haalth=false
fi

if ( [ "$kubeproxy_code_healthz" == "200" ] || [ "$kubeproxy_code_healthz" == "503" ] ) && [ "$kubeproxy_code_errortest" == "404" ]; then
  kubeproxy_health=true
else
  kubeproxy_haalth=false
fi

if [ "${kubelet_health}" == true ] && [ "${kubeproxy_health}" == true ]; then
  printf true
else
  printf false
fi
