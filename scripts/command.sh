#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

. $DIR_SCRIPTS/A0_initialize.sh
. $DIR_SCRIPTS/A1_create_os_img.sh
. $DIR_SCRIPTS/A2_create_strongswan_img.sh
. $DIR_SCRIPTS/A3_install_strongswan.sh
. $DIR_SCRIPTS/B1_create_vpn_vm_img.sh
. $DIR_SCRIPTS/B2_create_config.sh
. $DIR_SCRIPTS/B3_start_test.sh
. $DIR_SCRIPTS/B4_stop_test.sh
. $DIR_SCRIPTS/B5_remove_vm_vpn_config_img.sh

###############################################################
export TEST_DATE="$(date +%Y%m%d)"
export LOG_FILE=${DIR}/log/log${TEST_DATE}.txt

##################### check run condition #####################
echo_ok "command begin ...\n"

  load_global_id_from_file
  create_host_network   4 "10.4.0.100" "255.255.255.0"

  create_vm "vm4-1" $MEM_VM $CPU_VM         4 "10.4.0.10"  "255.255.255.0" "10.4.0.1" "10.4.255.255"
  create_vm "vm4-2" $MEM_VM $CPU_VM         4 "10.4.0.11"  "255.255.255.0" "10.4.0.1" "10.4.255.255"

  add_network "10.2.0.1"  4 "10.4.0.1"  "255.255.255.0"     # "0.0.0.0" "10.4.255.255"

  start_vm "vm4-1" 4
  start_vm "vm4-2" 4

echo_ok "command end."
