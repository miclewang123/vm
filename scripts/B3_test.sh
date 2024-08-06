#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

# run_test
# $1 - test name
start_test()
{
  start_vm "vm1" 2
  
  start_vpn "vpn1"
}

# stop_test
stop_test()
{  
  [ `id -u` -eq 0 ] || die "You must be root to run $0"

  echo "remove_vms:"
  remove_vms

  echo "remove_networks:"
  remove_networks
}
