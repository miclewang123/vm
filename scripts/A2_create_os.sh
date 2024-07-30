#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

echo "create os images begin ..."

DEV_NBD="/dev/nbd0"

##### check run condition #########


# create_base_os
# $1 - arch: amd64 or arm64
# $2 - os type: debian or ubuntu
create_base_os()
{
  ROOTFS_FILE=${DIR}/rootfs/rootfs_${2}_${1}.qcow2
  [ ! -f ${ROOTFS_FILE} ] ||  die "${ROOTFS_FILE} file is existed, please remove it first!"
  load_qemu_nbd
  #log_action "
  execute "qemu-img create -f qcow2 ${ROOTFS_FILE} 20G -o preallocation=off" 1
	execute "qemu-nbd -c ${DEV_NBD} ${ROOTFS_FILE}"
  execute "mkfs.ext4 ${DEV_NBD}"
  execute "mount ${DEV_NBD} ${DIR}/rootfs/mnt_rootfs/"
  execute "cp -af ${DIR}/rootfs/rootfs_${2}_${1}/* ${DIR}/rootfs/mnt_rootfs/"
  execute "umount ${DEV_NBD}"
  execute "chmod 777 ${ROOTFS_FILE}"
  execute "qemu-nbd -d ${DEV_NBD}"
}

create_base_os amd64 debian

echo "create os images end."
