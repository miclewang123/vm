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
  VM_UUID_ID=$(expr ${VM_UUID_ID} + 1)
  printf -v PAD_ID "%04d" "$VM_UUID_ID"
  VM_UUID="1f35c25d-6a7b-4ee1-2461-d7e51111${PAD_ID}"
}

# get_ipv6_addr
# no params
IPV6=""
get_ipv6_addr()
{
  IPV6_ID=$(expr ${IPV6_ID} + 1)
  printf -v PAD_ID "%04d" "$IPV6_ID"
  IPV6="${PAD_ID}::10"
}

# move_vm_vpn_xml_to_vms
# $1 - vm or vpn
# $2 - path: dst path of create_vm.xml or create_vpn.xml
move_vm_vpn_xml_to_vms()
{
  mkdir -p $2
  rm -f $1/create_$1.xml
  mv ${DIR_TPL}/create_$1.xml $2/
  # execute "chmod 777 $2/create_$1.xml"
}

# create_vm_vpn_xml
# $1 - type: vm or vpn
# $2 - NODE_NAME: node name
# $3 - ARCH: x86_64 or aarch64
# $4 - MEMORY(MB): memory
# $5 - VCPU: cpu count
# $6 - ROOT_FS: root file system
# $7 - BOOT_IMAGE: boot image
# $8 - QEMU_APP: qemu app name
# $9 - VNC: vnc port
# $10 - VM_UUID: vm UUID
# $11 - NET_MAC1: 
# $12 - NET_NO1: 
# $13 - NET_MAC2: 
# $14 - NET_NO2: 
create_vm_vpn_xml()
{
  FILE_TPL="${DIR_TPL}/create_$1.tpl"
  FILE_TPL_XML="${DIR_TPL}/create_$1.xml"
  cp -f ${FILE_TPL} ${FILE_TPL_XML}

  file_searchandreplace %NODE_NAME%     $2    $FILE_TPL_XML
  file_searchandreplace %ARCH%          $3    $FILE_TPL_XML
  file_searchandreplace %MEMORY%        $4    $FILE_TPL_XML
  file_searchandreplace %VCPU%          $5    $FILE_TPL_XML
  file_searchandreplace %ROOT_FS%       $6    $FILE_TPL_XML
  file_searchandreplace %BOOT_IMAGE%    $7    $FILE_TPL_XML
  file_searchandreplace %QEMU_APP%      $8    $FILE_TPL_XML
  file_searchandreplace %VNC%           $9    $FILE_TPL_XML
  file_searchandreplace %VM_UUID%       ${10} $FILE_TPL_XML

  file_searchandreplace %NET_MAC1%      ${11} $FILE_TPL_XML
  file_searchandreplace %NET_NAME1%     ${12} $FILE_TPL_XML
  if [ ! -z "${13}" ]; then
    file_searchandreplace %NET_MAC2%    ${13} $FILE_TPL_XML
    file_searchandreplace %NET_NAME2%   ${14} $FILE_TPL_XML
  fi
}

# create_interfaces
# $1 - type: vm or vpn
# $2 - eth0 ip address
# $3 - eth0 ip mask
# $4 - eth0 gw address
# $5 - eth0 broadcast address
# $6 - eth1 ip address
# $7 - eth1 ip mask
# $8 - eth1 gw address
# $9 - eth1 broadcast address
create_interfaces()
{
  FILE_TPL="${DIR_TPL}/interfaces_$1.tpl"
  FILE="${DIR_MNT}/etc/network/interfaces"
  cp -f ${FILE_TPL} ${FILE}

  file_searchandreplace %IP_0%            $2    $FILE
  file_searchandreplace %MASK_0%          $3    $FILE
  file_searchandreplace %GATEWAY_0%       $4    $FILE
  file_searchandreplace %BROADCAST_0%     $5    $FILE
  get_ipv6_addr
  file_searchandreplace %IPV6_0%          $IPV6 $FILE

  if [ ! -z "$6" ]; then
    file_searchandreplace %IP_1%          $6    $FILE
    file_searchandreplace %MASK_1%        $7    $FILE
    file_searchandreplace %GATEWAY_1%     $8    $FILE
    file_searchandreplace %BROADCAST_1%   $9    $FILE
    get_ipv6_addr
    file_searchandreplace %IPV6_1%        $IPV6 $FILE
  fi
}

# create_vm
# $1 - NODE_NAME: node name
# $2 - MEMORY(MB): memory
# $3 - VCPU: cpu count
# $4 - network no
# $5 - eth0 ip address
# $6 - eth0 ip mask
# $7 - eth0 gw address
# $8 - eth0 broadcast address
create_vm()
{
  PARENT_IMG="${DIR_ROOTFS}/rootfs_debian_amd64.${IMG_EXT}" 
  [ -f "${PARENT_IMG}" ] || die "${PARENT_IMG} is not exist!"

  VM_IMG="${DIR_VMS}/lan$4/$1/rootfs_vm_$1.${IMG_EXT}"
  create_img_from_parent ${VM_IMG} ${PARENT_IMG}

  # install
  load_qemu_nbd

  execute "qemu-nbd -c $DEV_NBD ${VM_IMG}"
  NBD_PARTITION=${DEV_NBD}
  execute "mount $NBD_PARTITION $DIR_MNT"
  #execute "mount -t proc none $DIR_MNT/proc"

  #execute "install ..."
  echo $1 > $DIR_MNT/etc/hostname 

  create_interfaces "vm" $5 $6 $7 $8

  #execute "umount $DIR_MNT/proc"
  execute "umount $DIR_MNT"
  execute "qemu-nbd -d $DEV_NBD"

  #
  IMAGE="${DIR_BOOT}/bzImage_amd64_virtio_9p"
  #IMAGE="${DIR_BOOT}/bzImage6-3"
  IMAGE=${IMAGE//\//\\\/}

  ROOT_FS=${VM_IMG//\//\\\/}
  
  get_mac_address
  NET_MAC1=$MAC_ADDR
  NET_NAME1="vnet$4"

  get_vnc_port
  get_uuid

  create_vm_vpn_xml "vm" $1 'x86_64' $2 $3 ${ROOT_FS} ${IMAGE} 'qemu-system-x86_64' ${VNC_PORT} ${VM_UUID} ${NET_MAC1} ${NET_NAME1}
  move_vm_vpn_xml_to_vms "vm" ${DIR_VMS}/lan$4/$1
}

# create_vpn
# $1 - NODE_NAME: node name
# $2 - MEMORY(MB): memory
# $3 - VCPU: cpu count
# $4 - eth0 network no
# $5 - eth0 ip address
# $6 - eth0 ip mask
# $7 - eth0 gw address
# $8 - eth0 broadcast address
# $9 - eth1 network no
# $10- eth1 ip address
# $11- eth1 ip mask
# $12- eth1 gw address
# $13- eth1 broadcast address
create_vpn()
{
  PARENT_IMG="${DIR_ROOTFS}/rootfs_strongswan.${IMG_EXT}" 
  [ -f "${PARENT_IMG}" ] || die "${PARENT_IMG} is not exist!"

  VM_IMG="${DIR_VMS}/vpn/$1/rootfs_vpn_$1.${IMG_EXT}"
  create_img_from_parent ${VM_IMG} ${PARENT_IMG}

  # install
  load_qemu_nbd

  execute "qemu-nbd -c $DEV_NBD ${VM_IMG}"
  NBD_PARTITION=${DEV_NBD}
  execute "mount $NBD_PARTITION $DIR_MNT"
  #execute "mount -t proc none $DIR_MNT/proc"

  #execute "install ..."
  echo $1 > $DIR_MNT/etc/hostname 
  create_interfaces "vpn" $5 $6 $7 $8 ${10} ${11} ${12} ${13}

  #execute "umount $DIR_MNT/proc"
  execute "umount $DIR_MNT"
  execute "qemu-nbd -d $DEV_NBD"

  #
  IMAGE="${DIR_BOOT}/bzImage_amd64_virtio_9p"
  #IMAGE="${DIR_BOOT}/bzImage6-3"
  IMAGE=${IMAGE//\//\\\/}

  ROOT_FS=${VM_IMG//\//\\\/}
  
  get_mac_address
  NET_MAC1=$MAC_ADDR
  NET_NAME1="vnet$4"
  get_mac_address
  NET_MAC2=$MAC_ADDR
  NET_NAME2="vnet$9"

  get_vnc_port
  get_uuid

  create_vm_vpn_xml "vpn" $1 'x86_64' $2 $3 ${ROOT_FS} ${IMAGE} 'qemu-system-x86_64' $VNC_PORT ${VM_UUID} $NET_MAC1 $NET_NAME1 $NET_MAC2 $NET_NAME2
  move_vm_vpn_xml_to_vms "vpn" ${DIR_VMS}/vpn/$1
}

# start_vm
# $1 - NODE_NAME: node name
# $2 - network_no: local network no
start_vm()
{
  VM_PATH="${DIR_VMS}/lan$2/$1"
  virsh create ${VM_PATH}/create_vm.xml

  if [ $? -eq 0 ]; then
    echo_ok "VM $1 start OK."
  else
    echo_failed "VM $1 start failed!"
  fi
}

# start_vpn
# $1 - NODE_NAME: node name
start_vpn()
{
  VM_PATH="${DIR_VMS}/vpn/$1"
  virsh create ${VM_PATH}/create_vpn.xml

  if [ $? -eq 0 ]; then
    echo_ok "VPN $1 start OK."
  else
    echo_failed "VPN $1 start failed!"
  fi
}
