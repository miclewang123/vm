#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

############## create host network #########################
# create_net_xml
# $1 - NET_NAME: network no
# $2 - BR_NAME: bridge name
# $3 - MAC: mac address
# $4 - IP: ip address
# $5 - IP_MASK: mask
# $6 - NET_UUID: net UUID
create_net_xml()
{
  FILE_TPL="${DIR_TPL}/create_net.tpl"
  FILE_TPL_XML="${DIR_VMS}/create_vnet$1.xml"
  cp -f ${FILE_TPL} ${FILE_TPL_XML}

  file_searchandreplace %NET_NAME%     vnet$1 $FILE_TPL_XML
  file_searchandreplace %BR_NAME%      $2     $FILE_TPL_XML
  file_searchandreplace %MAC%          $3     $FILE_TPL_XML
  file_searchandreplace %IP%           $4     $FILE_TPL_XML
  file_searchandreplace %IP_MASK%      $5     $FILE_TPL_XML
  file_searchandreplace %NET_UUID%     $6     $FILE_TPL_XML
}

# create_host_network
# $1 - network no
# $2 - ip
# $3 - ip_mask
create_host_network()
{
  BR_NAME="br$1"
  
  IP=$2
  IP_MASK=$3
  
  get_uuid
  NET_UUID=$VM_UUID

  get_mac_address
  create_net_xml $1 $BR_NAME $MAC_ADDR $IP $IP_MASK $NET_UUID
}

# start_host_network
# $1 - network no
start_host_network()
{
  virsh net-create ${DIR_VMS}/create_vnet$1.xml
}

################# add host network card ########################
# create_iface_xml
# $1 - tap name 
# $2 - network no
# $3 - slot no
create_iface_xml()
{
  FILE_TPL="$DIR_TPL/iface.tpl"
  FILE_TPL_XML="$DIR_TPL/iface.xml"
  cp -f ${FILE_TPL} ${FILE_TPL_XML}

  get_mac_address
  file_searchandreplace %TAP_NAME%     $1         $FILE_TPL_XML
  file_searchandreplace %NET_NAME%     "vnet$2"   $FILE_TPL_XML
  file_searchandreplace %NET_MAC%      $MAC_ADDR  $FILE_TPL_XML
  file_searchandreplace %SLOT%         $3         $FILE_TPL_XML
}

# get_last_tap_no
# $1 host name
TAP_NO=0
get_last_tap_no()
{
  ip addr | grep $1_tap${TAP_NO}
  while [ $? -eq 0 ]
  do
    TAP_NO=$(expr ${TAP_NO} + 1)
    ip addr | grep $1_tap${TAP_NO}
  done
}

# get_last_eth_no
# $1 host ip
ETH_NO=0
get_last_eth_no()
{
  ssh root@$1 ip addr | grep "eth${ETH_NO}: "
  while [ $? -eq 0 ]
  do
    ETH_NO=$(expr ${ETH_NO} + 1)
    ssh root@$1 ip addr | grep "eth${ETH_NO}: "
  done
}

# get_mask_count
# $1 - ip mask
MASK_COUNT=0
get_mask_count() 
{
  mask=$(echo "$1" | awk -F "." '{print $1" "$2" "$3" "$4}')

  MASK_COUNT=0
  for num in $mask;
  do
    while [ $num != 0 ];do
      if [ $(($num%2)) -eq 1 ]; then
        MASK_COUNT=$(expr ${MASK_COUNT} + 1)
      fi
      num=$(($num/2));
    done
  done
}

# get_subnet
# $1 ip
# $2 mask count
SUB_NET=""
get_subnet()
{
  ip=$1
  mask_count=$2
  ip_int=$(echo $ip | awk -F'.' '{print $1*(256^3) + $2*(256^2) + $3*256 + $4}')

  #主机位：32 - mask_count
  #按位运算，右移，ip地址移除主机位，保留网络位
  #按位运算，左移，ip地址以0补全主机位
  rev_mask_count=$(expr 32 - ${mask_count})
  ip_int=$(((10#${ip_int})>>${rev_mask_count}))
  ip_int=$((10#${ip_int}<<${rev_mask_count}))

  #获取子网, 整数转换ip地址, 整数右移取低8位
  ip1=$((10#${ip_int} >> 24))
  ip1=$((${ip1} & 0xFF))

  ip2=$((10#${ip_int} >> 16))
  ip2=$((${ip2} & 0xFF))
  
  ip3=$((10#${ip_int} >> 8))
  ip3=$((${ip3} & 0xFF))

  ip4=$((${ip_int} & 0xFF))
  
  SUB_NET="$ip1.$ip2.$ip3.$ip4"
}

# add network card to host ip
# $1 - HOST_IP: host ip
# $2 - ethX network no
# $3 - ethX ip
# $4 - ethX ip mask
# $5 - ethX gateway (no use)
# $6 - ethX broadcast (no use)
add_network_to_host()
{
  HOST_IP=$1
  HOST=`ssh root@$HOST_IP cat /etc/hostname`

  get_last_tap_no $HOST
  SLOT=$(expr $TAP_NO + 1)
  if [ $SLOT -lt 10 ]; then
    SLOT=10
  fi
  SLOT=$(printf "0x%x\n" ${SLOT})

  get_last_eth_no ${HOST_IP}

  NETWORK_NO=$2
  create_iface_xml ${HOST}_tap${TAP_NO} ${NETWORK_NO} ${SLOT}
  virsh attach-device $HOST "$DIR_TPL/iface.xml"

  NET_IP=$3
  
  get_mask_count $4
  NET_MASK_COUNT=$MASK_COUNT

  #NET_GATEWAY=$5
  get_subnet $NET_IP $NET_MASK_COUNT

  execute "ssh root@${HOST_IP} ip addr add $NET_IP/$NET_MASK_COUNT dev eth${ETH_NO};ip link set eth${ETH_NO} up"
  #execute "ssh root@${HOST_IP} ip route add ${SUB_NET}/$NET_MASK_COUNT via $NET_GATEWAY dev eth${ETH_NO}"
}

##########################################################################