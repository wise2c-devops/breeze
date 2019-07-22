#! /bin/bash

set -e

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -V -r | head -n 1)" != "$1"; }

[ ${BREEZE_LSB_ID} ]
[ ${BREEZE_LSB_RELEASE} ]
[ ${BREEZE_PYTHON_VERSION} ]

if [ "${BREEZE_LSB_ID}" != "RedHat" ] && [ "${BREEZE_LSB_ID}" != "CentOS" ] && [ "${BREEZE_LSB_ID}" != "Ubuntu" ]; then
  echo "Breeze currently only supports RedHat, CentOS and Ubuntu."
  exit
fi

if [ "${BREEZE_LSB_ID}" == "CentOS" ] && [ `version_lt 7.3 ${BREEZE_LSB_RELEASE}` ]; then
  echo "Breeze currently only supports RedHat/CentOS 7.4+ and Ubuntu 16/18."
  exit
fi

# TODO: complete unbuntu
if [ "${BREEZE_LSB_ID}" == "Ubuntu" ] && [ `version_lt 16 ${BREEZE_LSB_RELEASE}` ]; then
  echo "Breeze currently only supports RedHat/CentOS 7.4+ and Ubuntu 16/18."
  exit
fi

if [ `version_lt 2.7 ${BREEZE_PYTHON_VERSION}` ]; then
  echo "Breeze currently only supports python 2.7+"
  exit
fi

printf true
