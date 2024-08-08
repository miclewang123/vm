#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

# remove_vm_config_img
remove_vm_config_img()
{
  execute "rm -rf ${DIR_VMS}/lan*"
}

# remove_vpn_config_img
remove_vpn_config_img()
{
  execute "rm -rf ${DIR_VMS}/vpn"
}

# remove_host_network
remove_host_network()
{
  execute "rm -f ${DIR_VMS}/*"
}

# remove_config_img
remove_config_img()
{
  remove_vm_config_img
  remove_vpn_config_img
  
  remove_host_network

  execute "rm -f /var/host_share"
}