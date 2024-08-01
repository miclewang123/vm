#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

# run_test
# $1 - test name
start_test()
{
  start_vm "vm1" 1
  start_vpn "vpn1"

  config_vm_network
  config_vpn_network
  config_host_network
}

# stop_test
# $1 - test name
stop_test()
{  
  remove_net_config
}
