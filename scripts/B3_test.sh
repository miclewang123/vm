#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

echo "test begin ..."

export TEST_DATE="$(date +%Y%m%d%H%M%S)"
export LOGFILE=${DIR}/log/log${TEST_DATE}.txt



echo "test end."