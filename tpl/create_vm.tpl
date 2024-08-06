<domain type='kvm'>
  <name>%NODE_NAME%</name>
  <uuid>%VM_UUID%</uuid>
  <memory unit='MiB'>%MEMORY%</memory>
  <currentMemory unit='MiB'>%MEMORY%</currentMemory>
  <vcpu placement='static'>%VCPU%</vcpu>
  <os>
    <type arch='%ARCH%' machine='pc'>hvm</type>
    <kernel>%BOOT_IMAGE%</kernel>
    <cmdline>root=/dev/vda loglevel=1 console=hvc0 net.ifnames=0</cmdline>
    <boot dev='hd'/>
  </os>
  <cpu mode='host-passthrough'></cpu>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/bin/%QEMU_APP%</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2' cache='writethrough'/>
      <source file='%ROOT_FS%'/>
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </disk>
    <controller type='usb' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>

    <filesystem type='mount' accessmode='mapped'>
      <source dir='/var/run/hostshare'/>
      <target dir='/hostshare'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
    </filesystem>
    
    <interface type='network'>
      <mac address='%NET_MAC1%'/>
      <source network='%NET_NAME1%'/>
      <target dev='%NODE_NAME%_eth0'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>

    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='virtio' port='0'/>
    </console>
    <input type='tablet' bus='usb'/>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='%VNC%' autoport='no'/>
    <sound model='ich6'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </sound>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>


    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
    </memballoon>
    <rng model='virtio'>
      <backend model='random'>/dev/urandom</backend>
    </rng>
  </devices>
</domain>
