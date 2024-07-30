
 <domain type='kvm'>
    <name>%NODE_NAME%</name> 
    <memory unit='MiB'>%MEMORY%</memory>
    <currentMemory unit='MiB'>%MEMORY%</currentMemory>
    <vcpu>%VCPU%</vcpu> 
    <os>
        <type arch='%ARCH%' machine='pc'>hvm</type>
        <kernel>%BOOT_IMAGE%</kernel>
        <cmdline>root=/dev/vda1 loglevel=1 console=hvc0 net.ifnames=0</cmdline>
        <boot dev='hd'/> 
    </os>
    <cpu mode='host-model'></cpu>
    <features>
        <acpi/>
        <apic/>
        <pae/>
    </features>
    <clock offset='localtime'/>
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>restart</on_reboot>
    <on_crash>destroy</on_crash>
    <devices>
        <emulator>/usr/bin/%QEMU_APP%</emulator> 
        <disk type='file' device='disk'>
            <driver name='qemu' type='qcow2'/>
	          <source file='%ROOT_FS%'/>
            <target dev='sda' bus='scsi'/>
            <address type='drive' controller='0' bus='0' target='0' unit='0'/>      
        </disk>
        <controller type='scsi' index='0' model='virtio-scsi'/> 
        <disk type='file' device='cdrom'>
            <driver name='qemu' type='raw'/>
	          <source file=''/> 
            <target dev='hda' bus='ide'/>
            <readonly/>
            <address type='drive' controller='0' bus='1' target='0' unit='0'/>
        </disk>
        <interface type='bridge'>
            <source bridge='br0'/>
            <model type='virtio'/>
            <mac address='00:17:3E:64:01:01'/> 
            <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
        </interface>
        <input type='mouse' bus='ps2'/>
        <graphics type='vnc' port='%VNC%' autoport='yes' listen = '0.0.0.0' keymap='en-us'/>
        <video>
            <model type='cirrus' vram='9216' heads='1'/>
            <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
        </video>
        <memballoon model='virtio'>
            <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
        </memballoon>
        <serial type='pty'>
            <target port='0'/>
        </serial>
        <console type='pty'>
            <target type='serial' port='0'/>
        </console>
    </devices>
</domain>

    <cpu mode='custom'>
        <model>Westmere</model>
    </cpu>
    <vcpu>2</vcpu>
    <features>
        <acpi/>
        <apic/>
    </features>
    <os>
        <type arch='aarch64' machine='cortex-a57'>hvf</type>
        <bootmenu enable='yes'/>
    </os>
