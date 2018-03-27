#!/bin/bash

#Get macs and add to file for editing dhcp
DHCP_FILE=/home/imstof/10g-dhcp-macs
TENG_MAC=$(ip addr | grep -A1 p3p1 | grep link | awk '{print $2')
N1_MAC=$(ip addr | grep -A1 em1 | grep link | awk '{print $2}')

echo "host $(hostname -s)-10g {
     hardware ethernet $MAC;
     fixed-address $(hostname -s).inband.cluster;
}

#node $(hostname -s) {
#     hardware ethernet $N1MAC;
#     filename \"custom/uefi/elilo.efipxelinux.0\";
#     fixed-address $(hostname -s).inband.cluster;
#}

" >> $DHCP_FILE

#enable 10g dev at boot
sed -i 's/BOOT=no/BOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-p3p1

#dedicate ipmi
racadm set idrac.nic.selection 1

#edit bios settings for pxe boot
#get FQDDs for device and bios
DEV0=$(racadm get nic.nicconfig | awk '/Mezzanine/ {print $1;exit}')
DEV1=$(racadm get nic.nicconfig | awk -F'[=#]' '/Mezzanine/ {print $2;exit}')
if [[ $(racadm get bios.biosbootsettings | awk -F = '/BootMode/ {print $2}') == "Uefi" ]]
then
        BIOS=$(racadm get bios.networksettings.pxedev1endis  | awk -F'[=#]' '{print $2;exit}')
fi
#set device for legacy pxe
racadm set $DEV0.legacybootproto PXE
racadm jobqueue create $DEV1
if [[ -n $BIOS ]]
#enable device in uefi
then
        racadm set bios.networksettings.pxedev1endis Enabled
        racadm jobqueue create $BIOS
fi
#reboot node

