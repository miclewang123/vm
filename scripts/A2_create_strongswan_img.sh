#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

#create_img_from_parent
# $1 - new img name
# $2 - parent img name
create_img_from_parent()
{
#  DIR_MNT="${DIR}/loop"
  [ -d ${DIR_MNT} ] ||  mkdir -p ${DIR_MNT}

  DEV_NBD="/dev/nbd0"
  load_qemu_nbd

  [ ! -f ${Dir}/rootfs/qcow2/rootfs_strongswan.qcow2 ] || execute "rm -rf ${Dir}/rootfs/qcow2/rootfs_strongswan.qcow2"
  execute "qemu-img create -b $2 -f $IMG_EXT -F $IMG_EXT $1"
  
  execute "qemu-nbd -c $DEV_NBD $1"
  execute "partprobe $DEV_NBD"

  NBD_PARTITION=${DEV_NBD}
  execute "mount $NBD_PARTITION $DIR_MNT"
  execute "mount -t proc none $DIR_MNT/proc"

  execute "cp /etc/resolv.conf $DIR_MNT/etc/resolv.conf"

  execute "umount $DIR_MNT/proc"
  execute "umount $DIR_MNT"
  
  execute "qemu-nbd -d $DEV_NBD"


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

}

#create_strongswan_img
create_strongswan_img()
{
  STRONGSWAN_IMG="${DIR}/rootfs/qcow2/rootfs_strongswan.${IMG_EXT}"
  PARENT_IMG="${DIR}/rootfs/qcow2/rootfs_debian_amd64.${IMG_EXT}"

  execute "rm -rf ${STRONGSWAN_IMG}"
  create_img_from_parent ${STRONGSWAN_IMG} ${PARENT_IMG}
}