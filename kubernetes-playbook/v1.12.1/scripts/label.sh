HOSTNAME=`hostname`
while : ; do
  kubectl label --overwrite nodes ${HOSTNAME,,} io.wise2c.service=$1
  if [ $? != 0 ]; then
    sleep 2
  else break
  fi
done