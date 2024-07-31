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

[ `id -u` -eq 0 ] || die "You must be root to run $0"

VMS=`virsh list --name`
if [ -n "$VMS" ]; then
  read -p "Vms ($VMS) is running, close them first [y/n]?" continue
  if [[ $continue == 'y' || $continue == 'Y' ]]; then
    for VM in $VMS
    do
      execute "virsh destroy $VM"
    done
  else
    die "Please stop vms ($VMS) before continue $0"
  fi
fi

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
  execute "rm -rf ${DIR}/vms/lan*"
  execute "rm -rf ${DIR}/rootfs/qcow2/lan*/*.${IMG_EXT}"

  create_vm "vm1" 200 2 1
fi

if [ $BUILD_VPN = "yes" ];	then
  execute "rm -rf ${DIR}/vms/vpn"
  execute "rm -rf ${DIR}/rootfs/qcow2/vpn/*.${IMG_EXT}"
	
  create_vpn "vpn1" 200 2 0 
fi
echo "create vpn and vm end."


echo "test end."