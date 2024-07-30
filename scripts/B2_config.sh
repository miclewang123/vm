#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

echo "config network and certs begin ..."

##### check run condition #########


#set_network
#copy_vm_config_files

echo "config network and certs end."