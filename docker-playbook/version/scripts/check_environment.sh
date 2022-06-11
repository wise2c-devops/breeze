#! /bin/bash

set -e

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }

: '
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1"; }
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }
function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }
if version_gt $VERSION $VERSION2; then
   echo "$VERSION is greater than $VERSION2"
fi
if version_le $VERSION $VERSION2; then
   echo "$VERSION is less than or equal to $VERSION2"
fi
if version_lt $VERSION $VERSION2; then
   echo "$VERSION is less than $VERSION2"
fi
if version_ge $VERSION $VERSION2; then
   echo "$VERSION is greater than or equal to $VERSION2"
fi
'

[ ${BREEZE_LSB_ID} ]
[ ${BREEZE_LSB_RELEASE} ]
[ ${BREEZE_PYTHON_VERSION} ]

if [[ "${BREEZE_LSB_ID}" != "RedHat" ]] && [[ "${BREEZE_LSB_ID}" != "CentOS" ]] && [[ "${BREEZE_LSB_ID}" != "OracleLinux" ]] && [[ "${BREEZE_LSB_ID}" != "Rocky" ]] && [[ "${BREEZE_LSB_ID}" != "AlmaLinux" ]] && [[ "${BREEZE_LSB_ID}" != "Anolis" ]] && [[ "${BREEZE_LSB_ID}" != "Ubuntu" ]]; then
  echo "please use RHEL or CentOS or Ubuntu"
  exit
fi

if version_gt 7.4 ${BREEZE_LSB_RELEASE} && [[ "${BREEZE_LSB_ID}" == "RedHat" ]]; then
  echo "please use RHEL 7.x (x>3) for Breeze"
  exit
fi

if version_gt 7.4 ${BREEZE_LSB_RELEASE} && [[ "${BREEZE_LSB_ID}" == "CentOS" ]]; then
  echo "please use CentOS 7.x (x>3) for Breeze"
  exit
fi

if version_gt 18 ${BREEZE_LSB_RELEASE} && [[ "${BREEZE_LSB_ID}" == "Ubuntu" ]]; then
  echo "please use Ubuntu 18/20 for Breeze"
  exit
fi

if version_gt 2.7 ${BREEZE_PYTHON_VERSION}; then
  echo "please use python 2.7+"
  exit
fi

printf true
