#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

echo "test begin ..."

##### check run condition #########
#running_any $STRONGSWANHOSTS && die "Please stop test environment before running $0"

export TEST_DATE="$(date +%Y%m%d%H%M%S)"
export LOG_FILE=${DIR}/log/log${TEST_DATE}.txt




echo "test end."