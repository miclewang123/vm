#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

# remove_files
# remove_files()
# {
#   return
  # read -p "remove base image file [y/n]?" continue
  # if [[ $continue == 'y' || $continue == 'Y' ]]; then
    # execute "rm -rf ${DIR_ROOTFS}/rootfs_debian_amd64.${IMG_EXT}"
  # fi

  # read -p "remove strongswan image file [y/n]?" continue
  # if [[ $continue == 'y' || $continue == 'Y' ]]; then
    # execute "rm -rf ${DIR_ROOTFS}/rootfs_strongswan.${IMG_EXT}"
  # fi

  # read -p "remove vm files [y/n]?" continue
  # if [[ $continue == 'y' || $continue == 'Y' ]]; then
    # execute "rm -rf ${DIR_ROOTFS}/lan*/*.${IMG_EXT}"
  # fi

  # read -p "remove vpn files [y/n]?" continue
  # if [[ $continue == 'y' || $continue == 'Y' ]]; then
    # execute "rm -rf ${DIR_ROOTFS}/vpn/*.${IMG_EXT}"
  # fi

    # execute "rm -rf ${DIR_VMS}/*"

    # vms=`virsh list --name`
    # for vm in $vms
    # do
    #   execute "virsh destroy $vm"
    # done
# }

#create_folder
create_folder()
{
  [ -d  "${DIR_LOOP}" ] || mkdir -p "${DIR_LOOP}"
  [ -d  "${DIR_LOG}" ]  || mkdir -p "${DIR_LOG}"
  [ -d  "${DIR_VMS}" ]  || mkdir -p "${DIR_VMS}"
  [ -d  "${DIR_HOST_SHARE}" ]   || mkdir -p "${DIR_HOST_SHARE}"
  [ -L  "/var/host_share" ] || ln -fs "${DIR_HOST_SHARE}" /var/host_share
}
