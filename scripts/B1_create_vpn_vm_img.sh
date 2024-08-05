#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

##### check run condition #########

# get_mac_address
# no params
MAC_ADDR=""
get_mac_address()
{
  MAC_ID=$(expr ${MAC_ID} + 1)
  printf -v PAD_ID "%04d" "$MAC_ID"
  MAC_ADDR="52:54:00:71:${PAD_ID:0:2}:${PAD_ID:2:2}"
}

# get_vnc_port
# no params
get_vnc_port()
{
  VNC_PORT=$(expr ${VNC_PORT} + 1)
}

# get_uuid
# no params
VM_UUID=""
get_uuid()
{
  VM_UUID_NO=$(expr ${VM_UUID_NO} + 1)
  printf -v PAD_ID "%04d" "$VM_UUID_NO"
  VM_UUID="1f35c25d-6a7b-4ee1-2461-d7e51111${PAD_ID}"
}

# move_vm_xml_to_vms
# $1 - path: path of create_vm.xml
move_vm_xml_to_vms()
{
  mkdir -p $1
  rm -f $1/create_vm.xml
  mv ${DIR_TPL}/create_vm.xml $1/
  execute "chmod 777 $1/create_vm.xml"
}

# create_vm_xml
# $1 - NODE_NAME: node name
# $2 - ARCH: x86_64 or aarch64
# $3 - MEMORY(MB): memory
# $4 - VCPU: cpu count
# $5 - ROOT_FS: root file system
# $6 - BOOT_IMAGE: boot image
# $7 - QEMU_APP: qemu app name
# $8 - VNC: vnc port
# $9 - VM_UUID: vm UUID
# $10 - NET_MAC1: 
# $11 - NET_NO1: 
# $12 - NET_MAC2: 
# $13 - NET_NO2: 
# 
create_vm_xml()
{
  FILE_TPL="${DIR_TPL}/create_vm.tpl"
  FILE_TPL_XML="${DIR_TPL}/create_vm.xml"
  cp -f ${FILE_TPL} ${FILE_TPL_XML}

  file_searchandreplace %NODE_NAME%    $1 $FILE_TPL_XML
  file_searchandreplace %ARCH%         $2 $FILE_TPL_XML
  file_searchandreplace %MEMORY%       $3 $FILE_TPL_XML
  file_searchandreplace %VCPU%         $4 $FILE_TPL_XML
  file_searchandreplace %ROOT_FS%      $5 $FILE_TPL_XML
  file_searchandreplace %BOOT_IMAGE%   $6 $FILE_TPL_XML
  file_searchandreplace %QEMU_APP%     $7 $FILE_TPL_XML
  file_searchandreplace %VNC%          $8 $FILE_TPL_XML
  file_searchandreplace %VM_UUID%      $9 $FILE_TPL_XML

  file_searchandreplace %NET_MAC1%       ${10} $FILE_TPL_XML
  file_searchandreplace %NET_NAME1%      ${11} $FILE_TPL_XML
  if [ ! -z "${12}" ]; then
    file_searchandreplace %NET_MAC2%      ${12} $FILE_TPL_XML
    file_searchandreplace %NET_NAME2%     ${13} $FILE_TPL_XML
  fi
}

# $4 - bridge_no: local net bridge no
# $5 - ip address: local net ip
# $6 - gw address: local net gateway

# create_vm
# $1 - NODE_NAME: node name
# $2 - MEMORY(MB): memory
# $3 - VCPU: cpu count
# $4 - network no
create_vm()
{
  PARENT_IMG="${DIR}/rootfs/qcow2/rootfs_debian_amd64.${IMG_EXT}" 
  [ -f "${PARENT_IMG}" ] || die "${PARENT_IMG} is not exist!"

  NEW_IMG="${DIR}/rootfs/qcow2/lan$4/rootfs_vm_$1.${IMG_EXT}"
  create_img_from_parent ${NEW_IMG} ${PARENT_IMG}

  IMAGE="${DIR}/boot_image/bzImage_amd64_virtio_9p"
  #IMAGE="${DIR}/boot_image/bzImage6-3"
  IMAGE=${IMAGE//\//\\\/}

  ROOT_FS=$NEW_IMG
  ROOT_FS=${ROOT_FS//\//\\\/}
  
  get_mac_address
  NET_MAC1=$MAC_ADDR
  NET_NAME1="vnet$4"

  get_vnc_port
  get_uuid

  create_vm_xml $1 'x86_64' $2 $3 ${ROOT_FS} ${IMAGE} 'qemu-system-x86_64' ${VNC_PORT} ${VM_UUID} ${NET_MAC1} ${NET_NAME1}
  echo "move: ${DIR}/vms/lan$4/$1"
  move_vm_xml_to_vms ${DIR}/vms/lan$4/$1
}

# $4 - bridge_no: external net bridge no
# $5 - ip address: external net ip 
# $6 - gw address: external net gateway

# create_vpn
# $1 - NODE_NAME: node name
# $2 - MEMORY(MB): memory
# $3 - VCPU: cpu count
# $4 - network1 no
# $5 - network2 no
create_vpn()
{
  PARENT_IMG="${DIR}/rootfs/qcow2/rootfs_strongswan.${IMG_EXT}" 
  [ -f "${PARENT_IMG}" ] || die "${PARENT_IMG} is not exist!"

  NEW_IMG="${DIR}/rootfs/qcow2/vpn/rootfs_vpn_$1.${IMG_EXT}"
  create_img_from_parent ${NEW_IMG} ${PARENT_IMG}

  IMAGE="${DIR}/boot_image/bzImage_amd64_virtio_9p"
  #IMAGE="${DIR}/boot_image/bzImage6-3"
  IMAGE=${IMAGE//\//\\\/}

  ROOT_FS=${NEW_IMG}
  ROOT_FS=${ROOT_FS//\//\\\/}
  
  get_mac_address
  NET_MAC1=$MAC_ADDR
  NET_NAME1="vnet$4"
  get_mac_address
  NET_MAC2=$MAC_ADDR
  NET_NAME2="vnet$5"

  get_vnc_port
  get_uuid

  create_vm_xml $1 'x86_64' $2 $3 ${ROOT_FS} ${IMAGE} 'qemu-system-x86_64' $VNC_PORT ${VM_UUID} $NET_MAC1 $NET_NAME1 $NET_MAC2 $NET_NAME2
  move_vm_xml_to_vms ${DIR}/vms/vpn/$1
}

# start_vm
# $1 - NODE_NAME: node name
# $2 - network_no: local network no
start_vm()
{
  VM_PATH="${DIR}/vms/lan$2/$1"
  virsh create ${VM_PATH}/create_vm.xml

  if [ $? -eq 0 ]; then
    echo_ok "VM $1 create OK."
  else
    echo_failed "VM $1 create failed!"
  fi
}

# start_vpn
# $1 - NODE_NAME: node name
start_vpn()
{
  VM_PATH="${DIR}/vms/vpn/$1"
  virsh create ${VM_PATH}/create_vm.xml

  if [ $? -eq 0 ]; then
    echo_ok "VPN $1 create OK."
  else
    echo_failed "VPN $1 create failed!"
  fi
}

# # config_vm_network
# config_vm_network()
# {
#   return
# }

# # config_vpn_network
# config_vpn_network()
# {
#   return
# }