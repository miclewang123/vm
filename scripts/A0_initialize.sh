#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

# remove_files
remove_files()
{
  # read -p "remove base image file [y/n]?" continue
  # if [[ $continue == 'y' || $continue == 'Y' ]]; then
    # execute "rm -rf ${DIR}/rootfs/qcow2/rootfs_debian_amd64.${IMG_EXT}"
  # fi

  # read -p "remove strongswan image file [y/n]?" continue
  # if [[ $continue == 'y' || $continue == 'Y' ]]; then
    # execute "rm -rf ${DIR}/rootfs/qcow2/rootfs_strongswan.${IMG_EXT}"
  # fi

  # read -p "remove vm files [y/n]?" continue
  # if [[ $continue == 'y' || $continue == 'Y' ]]; then
    # execute "rm -rf ${DIR}/rootfs/qcow2/lan*/*.${IMG_EXT}"
  # fi

  # read -p "remove vpn files [y/n]?" continue
  # if [[ $continue == 'y' || $continue == 'Y' ]]; then
    # execute "rm -rf ${DIR}/rootfs/qcow2/vpn/*.${IMG_EXT}"
  # fi

    # execute "rm -rf ${DIR}/vms/*"

    # vms=`virsh list --name`
    # for vm in $vms
    # do
    #   execute "virsh destroy $vm"
    # done
}

#create_folder
create_folder()
{
  [ ! -d  "${DIR}/rootfs/qcow2" ] || mkdir -p "${DIR}/rootfs/qcow2"
  [ ! -d  "${DIR}/loop" ] || mkdir -p "${DIR}/loop"
  [ ! -d  "${DIR}/log" ] || mkdir -p "${DIR}/log"
  [ ! -d  "${DIR}/vms" ] || mkdir -p "${DIR}/vms"
  chmod -R +222 *
}
