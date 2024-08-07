#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh
. $DIR_SCRIPTS/A0_initialize.sh
. $DIR_SCRIPTS/A1_create_os_img.sh
. $DIR_SCRIPTS/A2_create_strongswan_img.sh
. $DIR_SCRIPTS/A3_install_strongswan.sh
. $DIR_SCRIPTS/B1_create_vpn_vm_img.sh
. $DIR_SCRIPTS/B2_config.sh
. $DIR_SCRIPTS/B3_test.sh
. $DIR_SCRIPTS/B4_remove_config.sh
. $DIR_SCRIPTS/B5_remove_img.sh

############ define step ######################################
if [ 1 -eq 1 ]; then
  export INITIALIZE="no"

  export BUILD_BASE="no"
  export BUILD_STRONGSWAN="no"

  export INSTALL_STRONGSWAN="no"

  export BUILD_VM="yes"
  export BUILD_VPN="yes"

# export BUILD_CERTS="no"
# export CONFIG_NET="yes"
  export RUN_TEST="yes"

  export STOP_TEST="no"
  export DESTROY_VM_VPN="no"
else
  export INITIALIZE="yes"

  export BUILD_BASE="yes"
  export BUILD_STRONGSWAN="yes"

  export INSTALL_STRONGSWAN="yes"

  export BUILD_VM="yes"
  export BUILD_VPN="yes"

# export BUILD_CERTS="yes"
# export CONFIG_NET="yes"
  export RUN_TEST="yes"

  export STOP_TEST="no"
  export DESTROY_VM_VPN="no"
fi

###############################################################
#export TEST_DATE="$(date +%Y%m%d%H%M%S)"
export TEST_DATE="$(date +%Y%m%d)"
export LOG_FILE=${DIR}/log/log${TEST_DATE}.txt

##################### check run condition #####################
echo_ok "run begin ...\n"

[ `id -u` -eq 0 ] || die "You must be root to run $0"

echo "remove_vms:"
remove_vms

echo "remove_networks:"
remove_networks

###############################################################
# A0 initialize
if [ $INITIALIZE = "yes" ];	then
  echo_ok "initialize begin ..."
  remove_files
  create_folder
  echo_ok "initialize end.\n"
fi

###############################################################
# A1 generate os base image
if [ $BUILD_BASE = "yes" ];	then
  echo_ok "create os images begin ..."
	create_base_os amd64 debian
  echo_ok "create os images end.\n"
fi

if [ $BUILD_STRONGSWAN = "yes" ];	then
  # A2 create_strongswan_img
  echo_ok "create strongswan image begin ..."
	create_strongswan_img 
  echo_ok "create strongswan image end.\n"
fi

###############################################################
# A3 install strongswan
if [ $INSTALL_STRONGSWAN = "yes" ];	then
  echo_ok "install strongswan begin ..."
  install_strongswan
  echo_ok "install strongswan end.\n"
fi

###############################################################
# B1 create vpn and vm
if [ $BUILD_VM = "yes" ];	then
  echo_ok "create vm begin ..."

  # $1 - NODE_NAME: node name
  # $2 - MEMORY(MB): memory
  # $3 - VCPU: cpu count
  # $4 - network no
  # $5 - eth0 ip address
  # $6 - eth0 ip mask
  # $7 - eth0 gw address
  # $8 - eth0 broadcast address
  create_vm "vm1" 200 2 2 "10.2.0.10"  "255.255.255.0" "10.2.0.1" "10.2.255.255"
  create_vm "vm2" 200 2 2 "10.2.0.11"  "255.255.255.0" "10.2.0.1" "10.2.255.255"

  echo_ok "create vm end.\n"
fi

if [ $BUILD_VPN = "yes" ];	then
  echo_ok "create vpn begin ..."

  # $1 - NODE_NAME: node name
  # $2 - MEMORY(MB): memory
  # $3 - VCPU: cpu count
  # $4 - eth0 network no
  # $5 - eth0 ip address
  # $6 - eth0 ip mask
  # $7 - eth0 gw address
  # $8 - eth0 broadcast address
  # $9 - eth1 network no
  # $10- eth1 ip address
  # $11- eth1 ip mask
  # $12- eth1 gw address
  # $13- eth1 broadcast address
  create_vpn "vpn1" 200 2         2 "10.2.0.1"  "255.255.255.0" "10.2.0.2" "10.2.255.255"      1 "192.168.0.10"  "255.255.255.0" "192.168.0.1" "192.168.255.255"
  echo_ok "create vpn end.\n"
fi

###############################################################
if [ $RUN_TEST = "yes" ];	then
  # B2 config
  echo_ok "config network and certs begin ..."
  config_host_network 1 "192.168.0.100" "255.255.255.0"
  config_host_network 2 "10.2.0.100" "255.255.255.0"
  config_host_network 3 "10.3.0.100" "255.255.255.0"
  echo_ok "config network and certs end.\n"

  # B3 test
  echo_ok "test begin ..."
  start_test 
  echo_ok "test end.\n"
fi

###############################################################
# B4 remove images
if [ $STOP_TEST = "yes" ];	then
  # B4 remove config
  echo_ok "stop test begin ..."
  stop_test 
  echo_ok "stop test end"
fi

###############################################################
# B5 remove images
if [ $DESTROY_VM_VPN = "yes" ];	then
  echo_ok "remove images begin ..."
  remove_vm_img
  remove_vpn_img
  echo_ok "remove images end.\n"
fi

###############################################################
echo_ok "run end."