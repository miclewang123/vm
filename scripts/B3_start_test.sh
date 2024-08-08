#!/bin/bash

DIR_SCRIPTS=$(dirname `readlink -f $0`)
. $DIR_SCRIPTS/function.sh

################ const define ###############
MEM_VM=200
MEM_VPN=1000
CPU_VM=2
CPU_VPN=4

#############################################
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

  # $1 - network no
  # $2 - ip
  # $3 - ip_mask
  create_host_network 1 "192.168.0.100" "255.255.255.0"
  create_host_network 2 "10.2.0.100" "255.255.255.0"
  create_host_network 3 "10.3.0.100" "255.255.255.0"
}

# run_test
# $1 - test name
start_test()
{
  # B2 config
  echo_ok "config network and certs begin ..."
  start_host_network 1
  start_host_network 2
  start_host_network 3
  echo_ok "config network and certs end.\n"

  # start vm vpn
  start_vm "vm2-1" 2
  start_vm "vm2-2" 2
  
  # start_vm "vm3-1" 3
  # start_vm "vm3-2" 3
  
  start_vpn "vpn_b1"
  # start_vpn "vpn_g1"

  save_global_id_to_file
}