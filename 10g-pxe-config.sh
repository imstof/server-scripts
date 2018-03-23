#!/bin/bash

#get FQDDs for device and bios
DEV0=$(racadm get nic.nicconfig | awk '/Mezzanine/ {print $1;exit}')
DEV1=$(racadm get nic.nicconfig | awk -F'[=#]' '{print $2;exit}')
if [[ $(racadm get bios.biosbootsettings | awk -F = '/BootMode/ {print $2;exit}') == "Uefi" ]]
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
