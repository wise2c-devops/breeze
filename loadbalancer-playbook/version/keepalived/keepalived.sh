#!/bin/bash

# Substitute variables in config file.
/bin/sed -i "s/{{VIRTUAL_IP}}/${VIRTUAL_IP}/g" /etc/keepalived/keepalived.conf
/bin/sed -i "s/{{CHECK_PORT}}/${CHECK_PORT}/g" /etc/keepalived/keepalived.conf
/bin/sed -i "s/{{RID}}/${RID}/g" /etc/keepalived/keepalived.conf
/bin/sed -i "s/{{VRID}}/${VRID}/g" /etc/keepalived/keepalived.conf
/bin/sed -i "s/{{INTERFACE}}/${INTERFACE}/g" /etc/keepalived/keepalived.conf
/bin/sed -i "s/{{NETMASK_BIT}}/${NETMASK_BIT}/g" /etc/keepalived/keepalived.conf
/bin/sed -i "s/{{MCAST_GROUP}}/${MCAST_GROUP}/g" /etc/keepalived/keepalived.conf

# Make sure we react to these signals by running stop() when we see them - for clean shutdown
# And then exiting
trap "stop; exit 0;" SIGTERM SIGINT

stop()
{
  # We're here because we've seen SIGTERM, likely via a Docker stop command or similar
  # Let's shutdown cleanly
  echo "SIGTERM caught, terminating keepalived process..."
  # Record PIDs
  pid=$(pidof keepalived)
  # Kill them
  kill -TERM $pid > /dev/null 2>&1
  # Wait till they have been killed
  wait $pid
  echo "Terminated."
  exit 0
}

# This loop runs till until we've started up successfully
while true; do
  # Check if Keepalived is running by recording it's PID (if it's not running $pid will be null):
  pid=$(pidof keepalived)
  # If $pid is null, do this to start or restart Keepalived:
  while [ -z "$pid" ]; do
    #Obviously optional:
    #echo "Starting Confd population of files..."
    #/usr/bin/confd -onetime
    echo "Displaying resulting /etc/keepalived/keepalived.conf contents..."
    cat /etc/keepalived/keepalived.conf
    echo "Starting Keepalived in the background..."
    /usr/sbin/keepalived --dont-fork --dump-conf --log-console --log-detail --vrrp &
    # Check if Keepalived is now running by recording it's PID (if it's not running $pid will be null):
    pid=$(pidof keepalived)
    # If $pid is null, startup failed; log the fact and sleep for 2s
    # We'll then automatically loop through and try again
    if [ -z "$pid" ]; then
      echo "Startup of Keepalived failed, sleeping for 2s, then retrying..."
      sleep 2
    fi
  done
  # Break this outer loop once we've started up successfully
  # Otherwise, we'll silently restart and Rancher won't know
  break
done
# Wait until the Keepalived processes stop (for some reason)
wait $pid
echo "The Keepalived process is no longer running, exiting..."
# Exit with an error
exit 1
