#!/bin/bash
# provides some general-purpose script functions
#
# Copyright (C) 2004  Eric Marchionni, Patrik Rayo
# Zuercher Hochschule Winterthur
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.  See <http://www.fsf.org/copyleft/gpl.txt>.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.

DIR_SCRIPTS="$(dirname `readlink -f $0`)"
export DIR="$(dirname ${DIR_SCRIPTS})"
export DIR_MNT=${DIR}/rootfs/mnt_rootfs
export DIR_TPL=${DIR}/tpl

export TERM=xterm
export MAC_ID=0
export VNC_PORT=5901
export VM_UUID_ID=0
export IMG_EXT="qcow2"
export IPV6_ID=0

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NORMAL=$(tput op)

if [ -z "$LOG_FILE" ]; then
  #TEST_DATE="$(date +%Y%m%d%H%M%S)"
  TEST_DATE=""
  export LOG_FILE=${DIR}/log/test${TEST_DATE}.log
fi

# exit with given error message
# $1 - error message
die() {
	echo -e "${RED}$1${NORMAL}"
	exit 1
}

##### check run condition #########
[ `id -u` -eq 0 ] || die "You must be root to run $0"
[ -d $DIR/log ] || die "log directory not found"
[ -d $DIR/vms ] || die "vms directory not found"


# execute command
# $1 - command to execute
# $2 - whether or not to log command exit status
#      (0 -> disable exit status logging)
execute()
{
	cmd=${1}
  echo command: $cmd 2>&1
	echo $cmd >>$LOG_FILE 2>&1
	$cmd >>$LOG_FILE 2>&1
	status=$?
	[ "$2" != 0 ] && log_status $status
	if [ $status != 0 ]; then
		echo
		echo "! Command $cmd failed, exiting (status $status)"
		echo "! Check why here $LOG_FILE"
		exit 1
	fi
}

# execute command in chroot
# $1 - command to execute
execute_chroot()
{
	execute "chroot $DIR_MNT env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@"
}

# write green status message to console
# $1 - msg
echo_ok()
{
	echo -e "${GREEN}$1${NORMAL}"
}

# write red status message to console
# $1 - msg
echo_failed()
{
	echo -e "${RED}$1${NORMAL}"
}

# write yellow status message to console
# $1 - msg
echo_warn()
{
	echo -e "${YELLOW}$1${NORMAL}"
}

# log an action
# $1 - current action description
log_action()
{
	/bin/echo -n "[....] $1 "
}

# log an action status
# $1 - exit status of action
log_status()
{
	tput hpa 0
	if [ $1 -eq 0 ]; then
		/bin/echo -ne "[${GREEN} ok ${NORMAL}"
	else
		/bin/echo -ne "[${RED}FAIL${NORMAL}"
	fi
	echo
}

# the following two functions are stolen from [1]
# [1] - http://www.linuxjournal.com/content/use-bash-trap-statement-cleanup-temporary-files

declare -a on_exit_items

# perform registered actions on exit
on_exit()
{
	for ((onex=${#on_exit_items[@]}-1; onex>=0; onex--))
	do
		echo "On_Exit: ${on_exit_items[$onex]}" >>$LOG_FILE
		${on_exit_items[$onex]} >>$LOG_FILE 2>&1
	done
	on_exit_items=""
	trap - EXIT
}

# register a command to execute when the calling script terminates. The
# registered commands are called in FILO order.
# $* - command to register
do_on_exit()
{
	local n=${#on_exit_items[*]}
	on_exit_items[$n]="$*"
	if [ $n -eq 0 ]; then
		trap on_exit EXIT
	fi
}

# wait for a mount to disappear
# $1 - device/image to wait for
# $2 - maximum time to wait in seconds, default is 5 seconds
graceful_umount()
{
	secs=$2
	[ ! $secs ] && secs=5

	let steps=$secs*100
	for st in `seq 1 $steps`
	do
		umount $1 >>$LOG_FILE 2>&1
		mount | grep $1 >/dev/null 2>&1
		[ $? -eq 0 ] || return 0
		sleep 0.01
	done

	return 1
}

# load qemu NBD kernel module, if not already loaded
load_qemu_nbd()
{
	lsmod | grep ^nbd[[:space:]]* >/dev/null 2>&1
	if [ $? != 0 ]
	then
		log_action "Loading NBD kernel module"
		execute "modprobe nbd max_part=16"
	fi
}

# check if given commands exist in $PATH
# $* - commands to check
check_commands()
{
	for i in $*
	do
		command -v $i >/dev/null || { die "Required command $i not found"; exit 1; }
	done
}

# check if any of the given virtual guests are running
# $* - names of guests to check
running_any()
{
	command -v virsh >/dev/null || return 1
	for host in $*
	do
		virsh list --name 2>/dev/null | grep "^$host$" >/dev/null && return 0
	done
	return 1
}

#############################################
# search and replace strings throughout a
# whole directory
#

function searchandreplace {

	SEARCHSTRING="$1"
	REPLACESTRING="$2"
	DESTDIR="$3"

	[ -d "$DESTDIR" ] || die "$DESTDIR is not a directory!"


	###########################################
	# search and replace in each found file the
	# given string
	#

	for eachfoundfile in `find $DESTDIR -type f`
	do
		sed -i -e "s/$SEARCHSTRING/$REPLACESTRING/g" "$eachfoundfile"
	done

}

#############################################
# search and replace strings in a file
#
function file_searchandreplace {

	SEARCHSTRING="$1"
	REPLACESTRING="$2"
	DESTFILE="$3"

	[ -f "$DESTFILE" ] || die "$DESTFILE is not a file!"

	sed -i -e "s/$SEARCHSTRING/$REPLACESTRING/g" "$DESTFILE"
}