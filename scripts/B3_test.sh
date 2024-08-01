#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh
. $DIR_SCRIPTS/A0_initialize.sh
. $DIR_SCRIPTS/A1_create_os_img.sh
. $DIR_SCRIPTS/A2_create_strongswan_img.sh
. $DIR_SCRIPTS/A3_install_strongswan.sh
. $DIR_SCRIPTS/B1_create_vpn_vm_img.sh
. $DIR_SCRIPTS/B2_config.sh
. $DIR_SCRIPTS/B4_remove_config.sh
. $DIR_SCRIPTS/B5_destroy_img.sh

############ define step #####################
export INITIALIZE="yes"

export BUILD_BASE="no"
export BUILD_STRONGSWAN="no"

export INSTALL_STRONGSWAN="yes"

export BUILD_VM="yes"
export BUILD_VPN="yes"

export CONFIG_NET="yes"
export RUN_TEST="yes"
##############################################

export TEST_DATE="$(date +%Y%m%d%H%M%S)"
export LOG_FILE=${DIR}/log/log${TEST_DATE}.txt

##### check run condition #########
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

echo_ok "begin ...\n"
# A0
if [ $INITIALIZE = "yes" ];	then
  echo_ok "initialize begin ..."
  remove_files
  create_folder
  echo_ok "initialize end.\n"
fi

# A1 generate file rootfs_debian_amd64.qcow2
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

if [ $INSTALL_STRONGSWAN = "yes" ];	then
  # A3 install strongswan
  echo_ok "install strongswan begin ..."
  install_strongswan
  echo_ok "install strongswan end.\n"
fi

# B1 create vpn and vm
if [ $BUILD_VM = "yes" ];	then
  echo_ok "create vm begin ..."
  execute "rm -rf ${DIR}/vms/lan*"
  execute "rm -rf ${DIR}/rootfs/qcow2/lan*/*.${IMG_EXT}"

  create_vm "vm1" 200 2 1
  echo_ok "create vm end.\n"
fi

if [ $BUILD_VPN = "yes" ];	then
  echo_ok "create vpn begin ..."
  execute "rm -rf ${DIR}/vms/vpn"
  execute "rm -rf ${DIR}/rootfs/qcow2/vpn/*.${IMG_EXT}"
	
  create_vpn "vpn1" 200 2 0 
  echo_ok "create vpn end.\n"
fi

if [ $CONFIG_NET = "yes" ];	then
  # B2 config
  echo_ok "config network and certs begin ..."
  config_vm_network
  config_vpn_network
  config_host_network
  echo_ok "config network and certs end.\n"
fi

if [ $RUN_TEST = "yes" ];	then
  echo_ok "test begin ..."

  echo_ok "test end.\n"

  echo_ok "remove config begin ..."
  remove_net_config
  echo_ok "remove config end.\n"

  echo_ok "destroy images begin ..."
  remove_vm_img
  remove_vpn_img
  echo_ok "destroy images end.\n"
fi
echo_ok "end."