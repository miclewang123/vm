#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh
. $DIR_SCRIPTS/A0_initialize.sh
. $DIR_SCRIPTS/A1_create_os_img.sh
. $DIR_SCRIPTS/A2_create_strongswan_img.sh
. $DIR_SCRIPTS/A3_install_strongswan_env.sh
. $DIR_SCRIPTS/B1_create_vpn_vm_img.sh
. $DIR_SCRIPTS/B2_config.sh
#. $DIR_SCRIPTS/B4_remove_config.sh
#. $DIR_SCRIPTS/B5_destroy_img.sh

echo "test begin ..."

##### check run condition #########
#running_any $STRONGSWANHOSTS && die "Please stop test environment before running $0"

export TEST_DATE="$(date +%Y%m%d%H%M%S)"
export LOG_FILE=${DIR}/log/log${TEST_DATE}.txt


# A0
if [ $BUILD_INITIALIZE = "yes" ];	then
  echo "initialize begin ..."
  remove_files
  create_folder
  echo "initialize end."
fi

# A1 generate file rootfs_debian_amd64.qcow2
if [ $BUILD_BASE = "yes" ];	then
  echo "create os images begin ..."
	create_base_os amd64 debian
  echo "create os images end."
fi

if [ $BUILD_STRONGSWAN = "yes" ];	then
  # A2 create_strongswan_img
  echo "create strongswan image begin ..."
	create_strongswan_img 
  echo "create strongswan image end."

  # A3 install strongswan
  echo "install strongswan env begin ..."

  echo "install strongswan env end."
fi

echo "create vpn and vm begin ..."
if [ $BUILD_GUEST = "yes" ];	then
  create_vm "vm1" 200 2 1
fi

if [ $BUILD_VPN = "yes" ];	then
	create_vpn "vpn1" 200 2 0 
fi
echo "create vpn and vm end."


echo "test end."