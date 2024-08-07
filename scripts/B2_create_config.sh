#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

##### check run condition #########
# create_net_xml
# $1 - NET_NAME: network no
# $2 - BR_NAME: bridge name
# $3 - MAC: mac address
# $4 - IP: ip address
# $5 - IP_MASK: mask
# $6 - NET_UUID: net UUID
create_net_xml()
{
  FILE_TPL="${DIR_TPL}/create_net.tpl"
  FILE_TPL_XML="${DIR}/vms/create_vnet$1.xml"
  cp -f ${FILE_TPL} ${FILE_TPL_XML}

  file_searchandreplace %NET_NAME%     vnet$1 $FILE_TPL_XML
  file_searchandreplace %BR_NAME%      $2     $FILE_TPL_XML
  file_searchandreplace %MAC%          $3     $FILE_TPL_XML
  file_searchandreplace %IP%           $4     $FILE_TPL_XML
  file_searchandreplace %IP_MASK%      $5     $FILE_TPL_XML
  file_searchandreplace %NET_UUID%     $6     $FILE_TPL_XML
}

#create_host_network
# $1 - network no
# $2 - ip
# $3 - ip_mask
create_host_network()
{
  BR_NAME="br$1"
  
  IP=$2
  IP_MASK=$3
  
  get_uuid
  NET_UUID=$VM_UUID

  get_mac_address
  create_net_xml $1 $BR_NAME $MAC_ADDR $IP $IP_MASK $NET_UUID
 
  virsh net-create ${DIR}/vms/create_vnet$1.xml
}

#########################################
# #config_network
# # $1 - vm name
# config_network()
# {
#   return
# }

# #get_vm_config
# # $1 - vm name
# get_vm_config()
# {
#   return
# }

# #config_vpn_network
# # $1 - vpn name
# config_vpn_network()
# {
#   return
# }

# #get_vpn_config
# # $1 - vpn name
# get_vpn_config()
# {
#   return
# }
#########################################