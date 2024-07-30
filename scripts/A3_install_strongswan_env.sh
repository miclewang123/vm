#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

##### install ##########
install_strongswan_env()
{
  INC=automake,autoconf,libtool,bison,flex,gperf,pkg-config,gettext,less,locales
  apt install -y $INC

  INC=build-essential,libgmp-dev,libldap2-dev,libcurl4-openssl-dev,ethtool
  apt install -y $INC

  INC=libxml2-dev,libtspi-dev,libsqlite3-dev,openssh-server,tcpdump,psmisc
  apt install -y $INC

  INC=openssl,vim,sqlite3,conntrack,gdb,cmake,libltdl-dev,wget,gnupg,man-db
  apt install -y $INC

  INC=libboost-thread-dev,libboost-system-dev,git,iperf,htop,valgrind,strace
  apt install -y $INC

  INC=gnat,gprbuild,acpid,acpi-support-base,libldns-dev,libunbound-dev
  apt install -y $INC

  INC=dnsutils,libsoup2.4-dev,ca-certificates,unzip,libsystemd-dev
  apt install -y $INC

  INC=python3,python3-setuptools,python3-dev,python3-daemon,python3-venv
  apt install -y $INC

  INC=apt-transport-https,libjson-c-dev,libxslt1-dev,libapache2-mod-wsgi-py3
  apt install -y $INC

  INC=libxerces-c-dev,rsyslog
  apt install -y $INC

  INC=iptables-dev
  apt install -y $INC
}

# install strongswan

