#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

############ define step ######################################
if [ 1 -eq 1 ]; then
  export INITIALIZE="yes"

  export BUILD_BASE="no"
  export BUILD_STRONGSWAN="no"

  export INSTALL_STRONGSWAN="no"

  export BUILD_VM_VPN="yes"

# export BUILD_CERTS="no"
# export CONFIG_NET="yes"
  export RUN_TEST="yes"

  export STOP_TEST="no"
  #export DESTROY_VM_VPN="no"
else
  export INITIALIZE="yes"

  export BUILD_BASE="yes"
  export BUILD_STRONGSWAN="yes"

  export INSTALL_STRONGSWAN="yes"

  export BUILD_VM_VPN="yes"

# export BUILD_CERTS="yes"
# export CONFIG_NET="yes"
  export RUN_TEST="yes"

  export STOP_TEST="no"
  #export DESTROY_VM_VPN="no"
fi

###############################################################