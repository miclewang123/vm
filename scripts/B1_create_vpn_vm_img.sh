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
  MAC_ADDR="52:54:00:71:${MAC_ID}:${MAC_ID}"
}

# get_vnc_port
# no params
get_vnc_port()
{
  VNC_PORT=$(expr ${VNC_PORT} + 1)
}

# move_xml_to_vms
# $1 - path: path of create_vm.xml
move_xml_to_vms()
{
  mkdir -p $1
  rm -f $1/create_vm.xml
  mv ${DIR_TPL}/create_vm.tpl.bak $1/create_vm.xml
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
create_vm_xml()
{
  FILE_TPL="${DIR_TPL}/create_vm.tpl"
  FILE_TPL_BAK="${DIR_TPL}/create_vm.tpl.bak"
  cp -f ${FILE_TPL} ${FILE_TPL_BAK}

  file_searchandreplace %NODE_NAME%    $1 $FILE_TPL_BAK
  file_searchandreplace %ARCH%         $2 $FILE_TPL_BAK
  file_searchandreplace %MEMORY%       $3 $FILE_TPL_BAK
  file_searchandreplace %VCPU%         $4 $FILE_TPL_BAK
  file_searchandreplace %ROOT_FS%      $5 $FILE_TPL_BAK
  file_searchandreplace %BOOT_IMAGE%   $6 $FILE_TPL_BAK
  file_searchandreplace %QEMU_APP%     $7 $FILE_TPL_BAK
  file_searchandreplace %VNC%          $8 $FILE_TPL_BAK
  file_searchandreplace %VM_UUID%      $9 $FILE_TPL_BAK
}

# create_vm
# $1 - NODE_NAME: node name
# $2 - MEMORY(MB): memory
# $3 - VCPU: cpu count
# $4 - bridge_no: local net bridge no
# $5 - ip address: local net ip
# $6 - gw address: local net gateway
create_vm()
{
  PARENT_IMG="${DIR}/rootfs/qcow2/rootfs_debian_amd64.${IMG_EXT}" 
  [ -f "${PARENT_IMG}" ] || die "${PARENT_IMG} is not exist!"

  NEW_IMG="${DIR}/rootfs/qcow2/lan$4/rootfs_vm_$1.${IMG_EXT}"
  create_img_from_parent ${NEW_IMG} ${PARENT_IMG}

  IMAGE="${DIR}/boot_image/bzImage_amd64_virtio"
  IMAGE=${IMAGE//\//\\\/}

  ROOT_FS=$NEW_IMG
  ROOT_FS=${ROOT_FS//\//\\\/}
  
  get_mac_address
  get_vnc_port

  create_vm_xml $1 'x86_64' $2 $3 ${ROOT_FS} ${IMAGE} 'qemu-system-x86_64' $VNC_PORT ${VM_UUID}${VNC_PORT}
  move_xml_to_vms ${DIR}/vms/lan$4/$1
}

# create_vpn
# $1 - NODE_NAME: node name
# $2 - MEMORY(MB): memory
# $3 - VCPU: cpu count
# $4 - bridge_no: external net bridge no
# $5 - ip address: external net ip 
# $6 - gw address: external net gateway
create_vpn()
{
  PARENT_IMG="${DIR}/rootfs/qcow2/rootfs_strongswan.${IMG_EXT}" 
  [ -f "${PARENT_IMG}" ] || die "${PARENT_IMG} is not exist!"

  NEW_IMG="${DIR}/rootfs/qcow2/vpn/rootfs_vpn_$1.${IMG_EXT}"
  create_img_from_parent ${NEW_IMG} ${PARENT_IMG}

  IMAGE="${DIR}/boot_image/bzImage_amd64_virtio"
  IMAGE=${IMAGE//\//\\\/}

  ROOT_FS=${NEW_IMG}
  ROOT_FS=${ROOT_FS//\//\\\/}
  
  get_mac_address
  get_vnc_port

  create_vm_xml $1 'x86_64' $2 $3 ${ROOT_FS} ${IMAGE} 'qemu-system-x86_64' $VNC_PORT ${VM_UUID}${VNC_PORT}
  move_xml_to_vms ${DIR}/vms/vpn/$1
}

# start_vm
# $1 - NODE_NAME: node name
# $2 - bridge_no: local net bridge no
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