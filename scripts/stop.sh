#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh
. $DIR_SCRIPTS/A0_initialize.sh
. $DIR_SCRIPTS/A1_create_os_img.sh
. $DIR_SCRIPTS/A2_create_strongswan_img.sh
. $DIR_SCRIPTS/A3_install_strongswan.sh
. $DIR_SCRIPTS/B1_create_vpn_vm_img.sh
. $DIR_SCRIPTS/B2_config.sh
. $DIR_SCRIPTS/B3_test.sh
. $DIR_SCRIPTS/B4_remove_config.sh
. $DIR_SCRIPTS/B5_remove_img.sh

###############################################################
export TEST_DATE="$(date +%Y%m%d)"
export LOG_FILE=${DIR}/log/log${TEST_DATE}.txt

##################### check run condition #####################
echo_ok "stop begin ...\n"
stop_test
echo_ok "stop end."
