HOST=debian10-amd64
echo $HOST > /etc/hostname
echo "auto lo" > /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo "allow-hotplug enp0s1" >> /etc/network/interfaces
echo "iface enp0s1 inet dhcp" >> /etc/network/interfaces
apt update
apt install net-tools openssh-server 
exit
apt install sudo
su wangyi
ls
exit
passwd root
USER= wangyi
useradd -G sudo -m -s /bin/bash $USER 
passwd $USER
USER=wangyi
useradd -G sudo -m -s /bin/bash $USER 
passwd $USER
ls
ls home
su wangyi
exit
cd /etc/
ls
ll login.defs
ls -l login.defs
vi login.defs
exit
passwd -d root
exit
vi /etc/login.defs
passwd root
passwd root
exit
passwd -d root
vi /etc
cd /etc
vi resolv.conf 
cat hosts
vi hosts
vi hosts
exit
