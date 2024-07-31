<domain type='qemu' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
    <name>ubuntu</name>
    <uuid>2005CB24-522A-4485-9B9A-E60A61D9F8CF</uuid>
    <memory unit='GB'>2</memory>
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
    <clock offset='localtime'/>
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>restart</on_reboot>
    <on_crash>destroy</on_crash>
    <pm>
        <suspend-to-mem enabled='no'/>
        <suspend-to-disk enabled='no'/>
    </pm>
    <devices>
        <emulator>/usr/local/bin/qemu-system-aarch64</emulator>
        <controller type='usb' model='ehci'/>
        <disk type='file' device='disk'>
            <driver name='qemu' type='qcow2'/>
            <source file='/Users/matthias/VM/Ubuntu_20.04-LTS/disk.qcow2'/>
            <target dev='vda' bus='virtio'/>
        </disk>
        <!--disk type='file' device='cdrom'>
            <source file='/Users/matthias/VM/Ubuntu_20.04-LTS/ubuntu-20.04.2-live-server-arm64.iso'/>
            <target dev='sdb' bus='sata'/>
        </disk-->
        <console type='pty'>
            <target type='serial'/>
        </console>
        <input type='tablet' bus='usb'/>
        <input type='keyboard' bus='usb'/>
        <graphics type='vnc' port='5900' listen='127.0.0.1'/>
        <video>
            <model type='virtio' vram='16384'/>
        </video>
    </devices>
    <seclabel type='none'/>
    <qemu:commandline>
        <!--qemu:arg value='-machine'/>
        <qemu:arg value='type=q35,accel=hvf'/>
        <qemu:arg value='-netdev'/>
        <qemu:arg value='user,id=n1,hostfwd=tcp::2222-:22'/>
        <qemu:arg value='-device'/>
        <qemu:arg value='virtio-net-pci,netdev=n1,bus=pcie.0,addr=0x19'/-->
    <qemu:arg value='-accel hvf -m 2048 -cpu cortex-a57 -M virt,highmem=off'/>
    <qemu:arg value='-drive file=/usr/local/share/qemu/edk2-aarch64-code.fd,if=pflash,format=raw,readonly=on'/>
    <qemu:arg value='-drive file=ovmf_vars.fd,if=pflash,format=raw'/>
    <qemu:arg value='-serial telnet::4444,server,nowait'/>
    <qemu:arg value='-device virtio-blk-device,drive=hd0,serial="dummyserial"'/>
    <qemu:arg value='-device virtio-net-device,netdev=net0'/>
    <qemu:arg value='-netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-0.0.0.0:22'/>
    <qemu:arg value='-vga none -device ramfb'/>
    <qemu:arg value='-device usb-ehci -device usb-kbd -device usb-mouse -usb'/>
    <qemu:arg value='-nographic -serial mon:stdio'/>
    </qemu:commandline>
</domain>