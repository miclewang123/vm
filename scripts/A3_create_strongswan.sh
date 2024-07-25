#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

echo "create strongswan image begin ..."

##### check run condition #########



qemu-img create -f qcow2 rootfs_debian_amd64.qcow2 20G -o preallocation=off
qemu-nbd -c /dev/nbd0 rootfs_debian_amd64.qcow2
mkfs.ext4 /dev/nbd0
mount /dev/nbd0 tmpfs/
cp -af rootfs_debian_amd64/* tmpfs/
umount /dev/nbd0
qemu-nbd -d /dev/nbd0


echo "create strongswan image end."