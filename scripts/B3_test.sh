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
# $1 - test name
stop_test()
{  
  return
}
