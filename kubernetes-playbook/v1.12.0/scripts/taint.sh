HOSTNAME=`hostname`
while : ; do
  kubectl taint --overwrite nodes ${HOSTNAME,,} node-role.kubernetes.io=master:NoSchedule
  if [ $? != 0 ]; then
    sleep 2
  else break
  fi
done