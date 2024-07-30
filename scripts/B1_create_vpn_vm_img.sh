#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh
. $DIR_SCRIPTS/A2_create_strongswan.sh

##### check run condition #########

# get_vm_uuid
# no params
get_vm_uuid()
{
  VM_UUID="${VM_UUID}${VNC_PORT}"
}

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

# for_create_vm
# $1 - NODE_NAME: node name
# $2 - ARCH: x86_64 or aarch64
# $3 - MEMORY(MB): memory
# $4 - VCPU: cpu count
# $5 - ROOT_FS: root file system
# $6 - BOOT_IMAGE: boot image
# $7 - QEMU_APP: qemu app name
# $8 - VNC: vnc port
# $9 - VM_UUID: vm UUID
for_create_vm()
{

  TPL_DIR=${DIR}/tpl
  TPL_BAK_DIR=${TPL_DIR}/bak
  \cp ${TPL_DIR}/create_vm.tpl ${TPL_BAK_DIR}/
  create_vm_xml $1 $2 $3 $4 $5 $6 $7 $8 $9
  mkdir -p ${DIR}/vms/$1/
  rm -f ${DIR}/vms/$1/create_vm.xml 
  mv ${TPL_BAK_DIR}/create_vm.tpl ${DIR}/vms/$1/create_vm.xml
  execute "chmod 777 ${DIR}/vms/$1/create_vm.xml"
  virsh create ${DIR}/vms/$1/create_vm.xml
  if [ $? -eq 0 ]; then
    echo_ok "vm $1 create OK."
  else
    echo_failed "vm $1 create failed!"
  fi
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
  searchandreplace %NODE_NAME%    $1 $TPL_BAK_DIR
  searchandreplace %ARCH%         $2 $TPL_BAK_DIR
  searchandreplace %MEMORY%       $3 $TPL_BAK_DIR
  searchandreplace %VCPU%         $4 $TPL_BAK_DIR
  searchandreplace %ROOT_FS%      $5 $TPL_BAK_DIR
  searchandreplace %BOOT_IMAGE%   $6 $TPL_BAK_DIR
  searchandreplace %QEMU_APP%     $7 $TPL_BAK_DIR
  searchandreplace %VNC%          $8 $TPL_BAK_DIR
  searchandreplace %VM_UUID%      $9 $TPL_BAK_DIR
}

# create_vm
# $1 - NODE_NAME: node name
# $2 - MEMORY(MB): memory
# $3 - VCPU: cpu count
# $4 - ip address: local net ip
# $5 - gw address: local net gateway
# $6 - bridge_no: local net bridge no
create_vm()
{
  PARENT_IMG="${DIR}/rootfs/qcow2/rootfs_debian_amd64.${IMG_EXT}" 
  [ ! -f "${PARENT_IMG}" ] || die "${PARENT_IMG} is not exist!"

  NEW_IMG="${DIR}/rootfs/qcow2/lan$6/rootfs_vm_$1.${IMG_EXT}"
  create_img_from_parent ${NEW_IMG} ${PARENT_IMG}

  IMAGE="${DIR}/boot_image/bzImage_amd64_virtio"
  IMAGE=${IMAGE//\//\\\/}

  ROOT_FS=$NEW_IMG
  ROOT_FS=${ROOT_FS//\//\\\/}
  
  get_vm_uuid
  get_mac_address
  get_vnc_port

  for_create_vm $1 "x86_64" $2 $3 ${ROOT_FS} ${IMAGE} "qemu-system-x86_64" $VNC_PORT $VM_UUID
}

# create_vpn
# $1 - NODE_NAME: node name
# $2 - MEMORY(MB): memory
# $3 - VCPU: cpu count
# $4 - ip address: external net ip 
# $5 - gw address: external net gateway
# $6 - bridge_no: external net bridge no
create_vpn()
{
  PARENT_IMG="${DIR}/rootfs/qcow2/rootfs_strongswan.${IMG_EXT}" 
  [ ! -f "${PARENT_IMG}" ] || die "${PARENT_IMG} is not exist!"

  NEW_IMG="${DIR}/rootfs/qcow2/vpn/rootfs_vpn_$1.${IMG_EXT}"
  create_img_from_parent ${NEW_IMG} ${PARENT_IMG}

  IMAGE="${DIR}/boot_image/bzImage_amd64_virtio"
  IMAGE=${IMAGE//\//\\\/}

  ROOT_FS=${NEW_IMG}
  ROOT_FS=${ROOT_FS//\//\\\/}
  
  get_vm_uuid
  get_mac_address
  get_vnc_port

  for_create_vm $1 "x86_64" $2 $3 ${ROOT_FS} ${IMAGE} "qemu-system-x86_64" $VNC_PORT $VM_UUID
}