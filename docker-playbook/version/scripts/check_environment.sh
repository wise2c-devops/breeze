#! /bin/bash

set -e

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

[ ${BREEZE_LSB_ID} ]
[ ${BREEZE_LSB_RELEASE} ]
#[ ${BREEZE_KERNEL} ]
[ ${BREEZE_PYTHON_VERSION} ]

if [ "${BREEZE_LSB_ID}" != "RedHat" ] && [ "${BREEZE_LSB_ID}" != "CentOS" ] && [ "${BREEZE_LSB_ID}" != "Ubuntu" ]; then
  echo "please use CentOS or Ubuntu"
  exit
fi

if [ "${BREEZE_LSB_ID}" == "RedHat" ] && [ `version_gt 7.3 ${BREEZE_LSB_RELEASE}` ]; then
  echo "please use RHEL 7.4/7.5/7.6/7.7 for Breeze"
  exit
fi

if [ "${BREEZE_LSB_ID}" == "CentOS" ] && [ `version_gt 7.3 ${BREEZE_LSB_RELEASE}` ]; then
  echo "please use CentOS 7.4/7.5/7.6/7.7 for Breeze"
  exit
fi

if [ "${BREEZE_LSB_ID}" == "Ubuntu" ] && [ `version_gt 16 ${BREEZE_LSB_RELEASE}` ]; then
  echo "please use Ubuntu 16 for Breeze"
  exit
fi

if [ `version_gt 2.7 ${BREEZE_PYTHON_VERSION}` ]; then
  echo "please use python 2.7+"
  exit
fi

printf true
