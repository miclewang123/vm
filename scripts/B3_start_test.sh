#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

################ const define ###############
MEM_VM=200
MEM_VPN=1000
CPU_VM=2
CPU_VPN=4

#############################################

# start_vm
# $1 - NODE_NAME: node name
# $2 - network_no: local network no
start_vm()
{
  VM_PATH="${DIR}/vms/lan$2/$1"
  virsh create ${VM_PATH}/create_vm.xml

  if [ $? -eq 0 ]; then
    echo_ok "VM $1 create OK."
  else
    echo_failed "VM $1 create failed!"
  fi
}

# start_vpn
# $1 - NODE_NAME: node name
start_vpn()
{
  VM_PATH="${DIR}/vms/vpn/$1"
  virsh create ${VM_PATH}/create_vpn.xml

  if [ $? -eq 0 ]; then
    echo_ok "VPN $1 create OK."
  else
    echo_failed "VPN $1 create failed!"
  fi
}


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

# get_last_tap_num
# $1 host name
TAP_NO=0
get_last_tap_no()
{
  ip addr | grep $1_tap$TAP_NO
  echo return ssh $?
  while [ $? -eq 0 ]
  do
    echo tap_no: $TAP_NO
    TAP_NO=$(expr ${TAP_NO} + 1)
    ip addr | grep $1_tap$TAP_NO
  done
  echo return tap_no: $TAP_NO
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

# add_network
# $1 - HOST_IP: host ip
# $2 - eth network no
# $3 - eth ip address
# $4 - eth ip mask
# $5 - eth gw address
add_network()
{
  HOST_IP=$1
  HOST=`ssh root@$HOST_IP cat /etc/hostname`

  get_last_tap_no $HOST
  SLOT=$(expr $TAP_NO + 1)
  if [ $SLOT -lt 10 ]; then
    SLOT=10
  fi

  NETWORK_NO=$2
  create_iface_xml ${HOST}_tap${TAP_NO} ${NETWORK_NO} ${SLOT}
  virsh attach-device $HOST "$DIR_TPL/iface.xml"

  NET_IP=$3
  
  get_mask_count $4
  NET_MASK_COUNT=$MASK_COUNT

  NET_GATEWAY=$5

  get_subnet $NET_IP $NET_MASK_COUNT

  execute "ssh root@${HOST_IP}  ip addr add $NET_IP/$NET_MASK_COUNT dev ${HOST}_tap${TAP_NO}; ip route add ${SUB_NET}/$NET_MASK_COUNT via $NET_GATEWAY dev ${HOST}_tap${TAP_NO}"
}

# create_vm_vpn_config
create_vm_vpn_config()
{
  # $1 - NODE_NAME: node name
  # $2 - MEMORY(MB): memory
  # $3 - VCPU: cpu count
  # $4 - eth0 network no
  # $5 - eth0 ip address
  # $6 - eth0 ip mask
  # $7 - eth0 gw address
  # $8 - eth0 broadcast address
  create_vm "vm2-1" $MEM_VM $CPU_VM         2 "10.2.0.10"  "255.255.255.0" "10.2.0.1" "10.2.255.255"
  create_vm "vm2-2" $MEM_VM $CPU_VM         2 "10.2.0.11"  "255.255.255.0" "10.2.0.1" "10.2.255.255"

  create_vm "vm3-1" $MEM_VM $CPU_VM         3 "10.3.0.10"  "255.255.255.0" "10.3.0.1" "10.3.255.255"
  create_vm "vm3-2" $MEM_VM $CPU_VM         3 "10.3.0.11"  "255.255.255.0" "10.3.0.1" "10.3.255.255"


  # $1 - NODE_NAME: node name
  # $2 - MEMORY(MB): memory
  # $3 - VCPU: cpu count
  # $4 - eth0 network no
  # $5 - eth0 ip address
  # $6 - eth0 ip mask
  # $7 - eth0 gw address
  # $8 - eth0 broadcast address
  # $9 - eth1 network no
  # $10- eth1 ip address
  # $11- eth1 ip mask
  # $12- eth1 gw address
  # $13- eth1 broadcast address
  create_vpn "vpn_b1" $MEM_VPN $CPU_VPN     1 "192.168.0.10"  "255.255.255.0" "192.168.0.1" "192.168.255.255"        2 "10.2.0.1"  "255.255.255.0" "0.0.0.0" "10.2.255.255"
  create_vpn "vpn_g1" $MEM_VPN $CPU_VPN     1 "192.168.0.11"  "255.255.255.0" "192.168.0.1" "192.168.255.255"        3 "10.3.0.1"  "255.255.255.0" "0.0.0.0" "10.3.255.255"
}

# run_test
# $1 - test name
start_test()
{
  # B2 config
  echo_ok "config network and certs begin ..."
  create_host_network 1 "192.168.0.100" "255.255.255.0"
  create_host_network 2 "10.2.0.100" "255.255.255.0"
  create_host_network 3 "10.3.0.100" "255.255.255.0"
  echo_ok "config network and certs end.\n"

  # start vm vpn
  start_vm "vm2-1" 2
  start_vm "vm2-2" 2
  
  # start_vm "vm3-1" 3
  # start_vm "vm3-2" 3
  
  start_vpn "vpn_b1"
  # start_vpn "vpn_g1"
}

#get_subnet
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
  ip_int=$(((10#${ip_int}) >> ${rev_mask_count}))
  ip_int=$((10#${ip_int} << ${rev_mask_count}))

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