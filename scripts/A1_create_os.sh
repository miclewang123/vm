#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

echo "create os images begin ..."

##### check command ########
check_commands bindfs debootstrap mkfs.ext4 sfdisk partprobe 
check_commands qemu-img qemu-nbd virsh qemu-system-x86_64
check_commands bunzip2 bzcat make wget

# create_base_os
# $1 - arch: amd64 or arm64
# $2 - os type: debian or ubuntu
create_base_os()
{
  DEV_NBD="/dev/nbd0"
  load_qemu_nbd

  BASE_ROOTFS=${DIR}/rootfs/rootfs_${2}_${1}.${IMG_EXT}
  [ ! -f ${BASE_ROOTFS} ] ||  die "${BASE_ROOTFS} file is existed, please remove it first!"
  
  execute "qemu-img create -f ${IMG_EXT} ${BASE_ROOTFS} 20G -o preallocation=off" 1
	execute "qemu-nbd -c ${DEV_NBD} ${BASE_ROOTFS}"
  execute "mkfs.ext4 ${DEV_NBD}"
  execute "mount ${DEV_NBD} ${DIR}/rootfs/mnt_rootfs/"
  execute "cp -af ${DIR}/rootfs/rootfs_${2}_${1}/* ${DIR}/rootfs/mnt_rootfs/"
  do_on_exit "umount ${DEV_NBD}"
  execute "chmod 777 ${BASE_ROOTFS}"
  do_on_exit "qemu-nbd -d ${DEV_NBD}"
}

create_base_os amd64 debian

echo "create os images end."