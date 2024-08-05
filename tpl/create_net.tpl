<network>
  <name>%NET_NAME%</name>
  <uuid>%NET_UUID%</uuid>
  <forward dev='lo' mode='route'>
    <interface dev='lo'/>
  </forward>
  <bridge name='%BR_NAME%' stp='on' delay='0' />
  <mac address='%MAC%'/>
  <ip address='%IP%' netmask='%IP_MASK%'>
  </ip>
</network>
