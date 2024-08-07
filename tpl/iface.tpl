<interface type='network'>
      <mac address='%NET_MAC%'/>
      <source network='%NET_NAME%'/>
      <target dev='%NODE_NAME%_tap0'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='%SLOT%' function='0x1'/>
</interface>