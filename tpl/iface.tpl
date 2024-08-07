<interface type='network'>
      <mac address='%NET_MAC%'/>
      <source network='%NET_NAME%'/>
      <target dev='%TAP_NAME%'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='%SLOT%' function='0x0'/>
</interface>