#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

##### check command ########
check_commands bindfs debootstrap mkfs.ext4 sfdisk partprobe 
check_commands qemu-img qemu-nbd virsh qemu-system-x86_64
check_commands bunzip2 bzcat make wget

# create_base_os
# $1 - arch: amd64 or arm64
# $2 - os type: debian or ubuntu
create_base_os()
{
  execute "rm -rf ${DIR}/rootfs/qcow2/rootfs_debian_amd64.${IMG_EXT}"

  DEV_NBD="/dev/nbd0"
  load_qemu_nbd

  BASE_ROOTFS=${DIR}/rootfs/qcow2/rootfs_${2}_${1}.${IMG_EXT}
  [ ! -f ${BASE_ROOTFS} ] ||  die "${BASE_ROOTFS} file is existed, please remove it first!"
  
  echo_ok "`date`, building $BASE_ROOTFS" >> $LOG_FILE

  execute "qemu-img create -f ${IMG_EXT} ${BASE_ROOTFS} 20G -o preallocation=off" 1
	execute "qemu-nbd -c ${DEV_NBD} ${BASE_ROOTFS}"
  execute "mkfs.ext4 ${DEV_NBD}"

  execute "mkdir -p ${DIR_MNT}"
  execute "mount ${DEV_NBD} ${DIR_MNT}"
  execute "cp -af ${DIR}/rootfs/rootfs_${2}_${1}/* ${DIR_MNT}"

#   # package includes/excludes
#   INC=automake autoconf libtool bison flex gperf pkg-config gettext less locales
#   INC=$INC build-essential libgmp-dev libldap2-dev libcurl4-openssl-dev ethtool
#   INC=$INC libxml2-dev libtspi-dev libsqlite3-dev openssh-server tcpdump psmisc
#   INC=$INC openssl vim sqlite3 conntrack gdb cmake libltdl-dev wget gnupg man-db
#   INC=$INC libboost-thread-dev libboost-system-dev git iperf htop valgrind strace
#   INC=$INC gnat gprbuild acpid acpi-support-base libldns-dev libunbound-dev
#   INC=$INC dnsutils libsoup2.4-dev ca-certificates unzip libsystemd-dev
#   INC=$INC python3 python3-setuptools python3-dev python3-daemon python3-venv 
#   INC=$INC apt-transport-https libjson-c-dev libxslt1-dev libapache2-mod-wsgi-py3
#   INC=$INC libxerces-c-dev rsyslog
#   INC=$INC iptables-dev
#   INC=$INC libahven7-dev libxmlada-schema8-dev libgmpada8-dev
#   INC=$INC libalog4-dev dbus-user-session

#   for package in $INC
#   do
#     execute_chroot "apt install -y $package"
#   done

#   log_action "Generating locales"
#   cat > ${DIR_MNT}/etc/locale.gen << EOF
# de_CH.UTF-8 UTF-8
# en_US.UTF-8 UTF-8
# EOF
#   execute_chroot "locale-gen"









#   SERVICES="apache2 dbus isc-dhcp-server slapd bind9 freeradius"

#   for package in $SERVICES
#   do
#     execute_chroot "apt install -y $package"
#   done

#   # read -p "press enter key to continue..."

#   # packages to install via APT, for SWIMA tests
#   APT1="libgcrypt20-dev traceroute iptables"
#   APT="tmux"
#   SERVICES="$SERVICES systemd-timesyncd"

#   log_action "Update package sources"
#   execute_chroot "apt-get update"
#   log_action "Install packages via APT"
#   execute_chroot "apt-get -y install $APT1"
#   log_action "Move history.log to history.log.1"
#   execute_chroot "mv /var/log/apt/history.log /var/log/apt/history.log.1"
#   log_action "Compress history.log.1 to history.log.1.gz"
#   execute_chroot "gzip /var/log/apt/history.log.1"
#   log_action "Install more packages via APT"
#   execute_chroot "apt-get -y install $APT"
#   log_action "Install packages from custom repo"
#   execute_chroot "apt-get -y upgrade"

#   for service in $SERVICES
#   do
#     log_action "Disabling service $service"
#     execute_chroot "systemctl disable $service"
#   done

#   log_action "Switching from iptables-nft to iptables-legacy"
#   execute_chroot "update-alternatives --set iptables /usr/sbin/iptables-legacy" 0
#   execute_chroot "update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy" 0
#   log_status 0

#   log_action "Disabling root password"
#   execute_chroot "passwd -d root"

  execute "umount ${DEV_NBD}"
  execute "chmod 777 ${BASE_ROOTFS}"

  execute "qemu-nbd -d ${DEV_NBD}"
}

  # BASE_IMG_ARCH="amd64"
  # BASE_IMG_SUITE="buster"
  # BASE_IMG_MIRROR="http://http.debian.net/debian"

  # CACHE_DIR=$DIR/cache
  # APT_CACHE=$DIR_MNT/var/cache/apt/archives

  # mkdir -p $CACHE_DIR
  # mkdir -p $APT_CACHE

  # log_action "Using $CACHE_DIR as archive for apt"
  # execute "mount -o bind $CACHE_DIR $APT_CACHE"
  # do_on_exit graceful_umount $APT_CACHE

  # execute "debootstrap --arch=$BASE_IMG_ARCH --include=$INC $BASE_IMG_SUITE $DIR_MNT $BASE_IMG_MIRROR"

  # execute "mount -t proc none $DIR_MNT/proc" 0
  # do_on_exit graceful_umount $DIR_MNT/proc

#   log_action "Downloading signing key for custom apt repo"
#   execute_chroot "wget -q $BASEIMGEXTKEY -O /tmp/key"
#   log_action "Installing signing key for custom apt repo"
#   execute_chroot "apt-key add /tmp/key"

#   log_action "Enabling custom apt repo"
#   cat > $DIR_MNT/etc/apt/sources.list.d/strongswan.list << EOF
#   deb $BASEIMGEXTREPO $BASEIMGSUITE main
# EOF
#   log_status $?

  # log_action "Prioritize custom apt repo"
  # cat > $DIR_MNT/etc/apt/preferences.d/strongswan.pref << EOF
  # Package: *
  # Pin: origin "$BASEIMGEXTREPOHOST"
  # Pin-Priority: 1001
  # EOF
  # log_status $?
