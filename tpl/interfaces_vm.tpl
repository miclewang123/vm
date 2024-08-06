auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
	address %IP_0%
	netmask %MASK_0%
	broadcast %BROADCAST_0%
	gateway %GATEWAY_0%
iface eth0 inet6 static
	address %IPV6_0%
	netmask 16
