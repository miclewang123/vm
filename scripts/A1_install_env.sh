#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

echo "install strongswan env begin ..."

##### check run condition #########
#running_any $STRONGSWANHOSTS && die "Please stop test environment before running $0"

##### check command ########
check_commands bindfs
check_commands debootstrap mkfs.ext3 partprobe qemu-img qemu-nbd sfdisk
check_commands partprobe qemu-img qemu-nbd
check_commands virsh qemu-system-x86_64
check_commands bunzip2 bzcat make wget

##### install ##########
#apt install XXX

echo "install strongswan env end."
