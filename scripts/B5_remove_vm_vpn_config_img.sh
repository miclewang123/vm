#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

# remove_vm_config_img
remove_vm_config_img()
{
  execute "rm -rf ${DIR}/vms/lan*"
  execute "rm -rf ${DIR}/rootfs/qcow2/lan*/*.${IMG_EXT}"
}

# remove_vpn_config_img
remove_vpn_config_img()
{
  execute "rm -rf ${DIR}/vms/vpn"
  execute "rm -rf ${DIR}/rootfs/qcow2/vpn/*.${IMG_EXT}"
}

# remove_config_img
remove_config_img()
{
  remove_vm_config_img
  remove_vpn_config_img
}