======================== A1. host install ====================================
1. install strongswan env；

======================== A2. make base OS image ==============================

1. call create_os.sh only one time, to create os image of echo release version;

======================== A3. make strongswan image ===========================

1. base on the os image above, call create_strongswan.sh to create increase image, 
   and install strongswan and runtime env in this image;

==============================================================================
==============================================================================

======================== B1. make vm and vpn image ===========================

1. read vm or vpn information from file test.conf

2. base on os image, call create_vm.sh to create vm increase image, and copy vm ip 
   and settings to the img;

3. base on strongswan image, call create_vpn.sh to create vpn increase image, 
   and copy vpn ip to the img;

4. start vm and vpn OS;

======================== B2. config ==========================================

1. read iptables, rules and set iptables and rules of each vm or vpn;

2. make certs and copy certs to vpn;

3. create bridge device to emulate the network segment in vm;

4. connect each network segment of each vm;

======================== B3. start test =====================================

1. run test case (include start/stop strongswan etc) and log the test result in test.txt;

2. compare test.txt to the right test result test_right.txt automatically, 
   if no change, test pass, else no pass;

======================== B4. remove config ======================================

1. remove certs;

2. remove iptable and rules setting;

======================== B5. destroy vm and vpn images ========================

1. stop vm and vpn OS;
2. destroy vm and vpn images;

==============================================================================
==============================================================================

注：
A is prepare image；
  1. "A1. host install" and "A2. make base OS image" only need to be run once;
  2. "A3. make strongswan image" only need to be done when strongswan is modified;

B is test；
  1. B1 and B2 only need to be done once in a test;
  2. B3 can be run multiple times;
  3. B4 is need to be run when certs or iptables、rules is modified;
  4. B5 is called when this test environment is no needed;
