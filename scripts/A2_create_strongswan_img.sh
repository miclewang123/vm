#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

# install_strongswan_env
install_strongswan_env()
{
  return 0
  # INC=automake,autoconf,libtool,bison,flex,gperf,pkg-config,gettext,less,locales
  # apt install -y $INC

  # INC=build-essential,libgmp-dev,libldap2-dev,libcurl4-openssl-dev,ethtool
  # apt install -y $INC

  # INC=libxml2-dev,libtspi-dev,libsqlite3-dev,openssh-server,tcpdump,psmisc
  # apt install -y $INC

  # INC=openssl,vim,sqlite3,conntrack,gdb,cmake,libltdl-dev,wget,gnupg,man-db
  # apt install -y $INC

  # INC=libboost-thread-dev,libboost-system-dev,git,iperf,htop,valgrind,strace
  # apt install -y $INC

  # INC=gnat,gprbuild,acpid,acpi-support-base,libldns-dev,libunbound-dev
  # apt install -y $INC

  # INC=dnsutils,libsoup2.4-dev,ca-certificates,unzip,libsystemd-dev
  # apt install -y $INC

  # INC=python3,python3-setuptools,python3-dev,python3-daemon,python3-venv
  # apt install -y $INC

  # INC=apt-transport-https,libjson-c-dev,libxslt1-dev,libapache2-mod-wsgi-py3
  # apt install -y $INC

  # INC=libxerces-c-dev,rsyslog
  # apt install -y $INC

  # INC=iptables-dev
  # apt install -y $INC
}

#create_img_from_parent
# $1 - new img name
# $2 - parent img name
create_img_from_parent()
{
  [ -d ${DIR_MNT} ] ||  mkdir -p ${DIR_MNT}

  load_qemu_nbd

  [ -f $1 ] || execute "rm -f $1"

  DIR_NEW_IMG=$(dirname $1)
  [ -d ${DIR_NEW_IMG} ] ||  mkdir -p ${DIR_NEW_IMG}

  execute "qemu-img create -b $2 -f $IMG_EXT -F $IMG_EXT $1"
  
  execute "qemu-nbd -c $DEV_NBD $1"
  execute "partprobe $DEV_NBD"

  NBD_PARTITION=${DEV_NBD}
  execute "mount $NBD_PARTITION $DIR_MNT"
  execute "mount -t proc none $DIR_MNT/proc"

  execute "cp /etc/resolv.conf $DIR_MNT/etc/resolv.conf"

  execute "cp ${DIR_ETC}/fstab $DIR_MNT/etc/"
  #execute "echo /dev/vda  /  ext4  defaults,relatime,barrier=1 0 1 > $DIR_MNT/etc/fstab"

  execute "umount $DIR_MNT/proc"
  execute "umount $DIR_MNT"
  
  execute "qemu-nbd -d $DEV_NBD"
}

#create_strongswan_img
create_strongswan_img()
{
  STRONGSWAN_IMG="${DIR_ROOTFS}/rootfs_strongswan.${IMG_EXT}"
  PARENT_IMG="${DIR_ROOTFS}/rootfs_debian_amd64.${IMG_EXT}"

  execute "rm -rf ${STRONGSWAN_IMG}"
  create_img_from_parent ${STRONGSWAN_IMG} ${PARENT_IMG}

  # install
  load_qemu_nbd
  execute "qemu-nbd -c $DEV_NBD ${STRONGSWAN_IMG}"

  NBD_PARTITION=${DEV_NBD}
  execute "mount $NBD_PARTITION $DIR_MNT"
  execute "mount -t proc none $DIR_MNT/proc"

  execute "install_strongswan_env"

  execute "umount $DIR_MNT/proc"
  execute "umount $DIR_MNT"
  
  execute "chmod 777 ${STRONGSWAN_IMG}"
  
  execute "qemu-nbd -d $DEV_NBD"
}

  # mkdir -p $SHARED_DIR
  # mkdir -p $DIR_MNT/root/shared
  # log_action "Mounting $SHARED_DIR as /root/shared"
  # execute "mount -o bind $SHARED_DIR $DIR_MNT/root/shared"
  # do_on_exit umount $DIR_MNT/root/shared

  # log_action "Copy /etc/resolv.conf"
  # execute "cp /etc/resolv.conf $DIR_MNT/etc/resolv.conf"
  # do_on_exit rm $DIR_MNT/etc/resolv.conf

  # log_action "Remove SWID tags of previous strongSwan versions"
  # execute_chroot "find /usr/local/share -path '*strongswan*' -name *.swidtag -delete"

  # if [ -z "$TARBALL" ]; then
  #   SRC_UID=$(stat -c '%u' $SWAN_DIR)
  #   SRC_GID=$(stat -c '%g' $SWAN_DIR)
  #   SRC_USER=$(stat -c '%U' $SWAN_DIR)

  #   mkdir -p $DIR_MNT/root/strongswan
  #   log_action "Mounting $SWAN_DIR as /root/strongswan"
  #   execute "bindfs -u $SRC_UID -g $SRC_GID --create-for-user=$SRC_UID --create-for-group=$SRC_GID $SWAN_DIR $DIR_MNT/root/strongswan"
  #   do_on_exit umount $DIR_MNT/root/strongswan

  #   log_action "Determine strongSwan version"
  #   desc=`runuser -u $SRC_USER -- git -C $SWAN_DIR describe --exclude 'android-*' --dirty`
  #   if [ $? -eq 0 ]; then
  #     version="$desc (`runuser -u $SRC_USER -- git -C $SWAN_DIR rev-parse --abbrev-ref HEAD`)"
  #   else
  #     version="`cat $SWAN_DIR/configure.ac | sed -n '/^AC_INIT/{ s/.*,\[\(.*\)\])$/\1/p }'`"
  #   fi
  #   echo "$version" > $SHARED_DIR/.strongswan-version
  #   log_status 0

  #   log_action "Preparing source tree"
  #   execute_chroot 'autoreconf -i /root/strongswan'
  # fi

  # RECPDIR=$DIR/recipes
  # if [ "$ALL_RECIPES" ]; then
  #   echo "Building and installing strongSwan and all other software"
  #   if [ -d "$RECPDIR/patches" ]
  #   then
  #     execute "cp -r $RECPDIR/patches $DIR_MNT/root/shared/compile" 0
  #   fi
  #   RECIPES=`ls $RECPDIR/*.mk | xargs -n1 basename`
  #   log_action "Whitelist all Git repositories"
  #   echo "[safe]"             > $DIR_MNT/root/.gitconfig
  #   echo "    directory = *" >> $DIR_MNT/root/.gitconfig
  #   log_status 0
  # else
  #   echo "Building and installing strongSwan"
  #   RECIPES=`ls $RECPDIR/*strongswan.mk | xargs -n1 basename`
  # fi

  # if [ "$CLEAN" ]; then
  #   rm -rf $SHARED_DIR/build-strongswan
  # fi
  # mkdir -p $SHARED_DIR/build-strongswan
  # mkdir -p $SHARED_DIR/compile

  # for r in $RECIPES
  # do
  #   log_action "Installing from recipe $r"
  #   if [[ $r == *strongswan.mk && -z "$TARBALL" ]]; then
  #     cp $RECPDIR/$r $SHARED_DIR/build-strongswan
  #     execute_chroot "make SRC_DIR=/root/strongswan BUILDDIR=/root/shared/build-strongswan -f /root/shared/build-strongswan/$r"
  #   else
  #     cp $RECPDIR/$r ${DIR_MNT}/root/shared/compile
  #     execute_chroot "make SWANVERSION=$TARBALL -C /root/shared/compile -f $r"
  #   fi
  # done

  # # rebuild the guest images after we modified the root image
  # if [ -z "$GUEST" -a -z "$NO_GUESTS" ]; then
  #   # cleanup before mounting guest images
  #   on_exit
  #   # building the guest images without certificates fails on winnetou
  #   if [ ! -f "$DIR/../hosts/winnetou/etc/ca/strongswanCert.pem" ]; then
  #     # this also re-builds the guest images
  #     $DIR/build-certs
  #   else
  #     $DIR/build-guestimages
  #   fi
  # fi

  #execute "rm -rf $DIR_MNT/*"
