#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

. $DIR_SCRIPTS/A0_initialize.sh
. $DIR_SCRIPTS/A1_create_os_img.sh
. $DIR_SCRIPTS/A2_create_strongswan_img.sh
. $DIR_SCRIPTS/A3_install_strongswan.sh
. $DIR_SCRIPTS/B1_create_vpn_vm_img.sh
. $DIR_SCRIPTS/B2_create_config.sh
. $DIR_SCRIPTS/B3_start_test.sh
. $DIR_SCRIPTS/B4_stop_test.sh
. $DIR_SCRIPTS/B5_remove_vm_vpn_config_img.sh

. $DIR_SCRIPTS/config.sh

###############################################################
#export TEST_DATE="$(date +%Y%m%d%H%M%S)"
export TEST_DATE="$(date +%Y%m%d)"
export LOG_FILE=${DIR}/log/log${TEST_DATE}.txt

echo_ok "run begin ...\n"
##################### check run condition #####################
# run condition check
[ `id -u` -eq 0 ] || die "You must be root to run $0"

check_commands bindfs debootstrap mkfs.ext4 sfdisk partprobe 
check_commands qemu-img qemu-nbd virsh qemu-system-x86_64
check_commands bunzip2 bzcat make wget

stop_test

###############################################################
# A0 initialize
if [ $INITIALIZE = "yes" ];	then
  echo_ok "initialize begin ..."
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
# B1 create vpn and vm config
if [ $BUILD_VM_VPN = "yes" ];	then
  echo_ok "create vm and vpn config begin ..."
  create_vm_vpn_config
  echo_ok "create vm and vpn end.\n"
fi

###############################################################
if [ $RUN_TEST = "yes" ];	then
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
echo_ok "run end."