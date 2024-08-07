#!/bin/bash
DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

# destroy_networks
destroy_networks()
{
	VNETS=`virsh net-list --name`

  if [ -n "$VNETS" ]; then
  #  read -p "VNET ($VNET) is running, close them first [y/n]?" continue
  #  if [[ $continue == 'y' || $continue == 'Y' ]]; then
      for VNET in $VNETS
      do
        log_action "virsh net-destroy $VNET"
        execute "virsh net-destroy $VNET"
      done
  #  else
  #    die "Please stop vms ($VNET) before continue $0"
  #  fi
  fi
}

# destroy_vms
destroy_vms()
{
  VMS=`virsh list --name`
  if [ -n "$VMS" ]; then
  #  read -p "Vms ($VMS) is running, close them first [y/n]?" continue
  #  if [[ $continue == 'y' || $continue == 'Y' ]]; then
      for VM in $VMS
      do
        execute "virsh destroy $VM"
      done
  #  else
  #    die "Please stop vms ($VMS) before continue $0"
  #  fi
  fi
}

# stop_test
stop_test()
{  
  [ `id -u` -eq 0 ] || die "You must be root to run $0"

  echo "destroy_vms:"
  destroy_vms

  echo "destroy_networks:"
  destroy_networks

  umount ${DIR_MNT}/proc
  umount ${DIR_MNT}
  execute "qemu-nbd -d ${DEV_NBD}"
}
