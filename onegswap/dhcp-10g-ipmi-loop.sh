#!/bin/bash

for node in $(nodeset -e node[972-1014])
do
# send macs to file for dhcp
	echo "fetching mac for $node"
	N1MAC=$(ssh $node 'ip addr' | grep -A1 em1 | grep link | awk '{print $2}')
	MAC=$(ssh $node 'ip addr' | grep -A1 p3p1 | grep link | awk '{print $2}')
	echo "adding 10g-mac $MAC and nic1-mac $N1MAC to /home/imstof/10g-dhcp"
	echo "host $node-10g {
     hardware ethernet $MAC;
     fixed-address $node.inband.cluster;
}

#node $node {
#     hardware ethernet $N1MAC;
#     filename \"custom/uefi/elilo.efipxelinux.0\";
#     fixed-address $node.inband.cluster;
#}

" >> /home/imstof/10g-dhcp

# configure 10g port
	echo "setting ifcfg-p3p1 for $node"
	ssh $node "sed -i 's/BOOT=no/BOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-p3p1"
	if [[ -n $(ssh $node 'cat /etc/sysconfig/network-scripts/ifcfg-p3p1' | grep BOOT=yes) ]]
	then
		echo success
	else
		echo FAILED!
	fi

# dedicate ipmi port
	echo "setting dedicated ipmi port for $node"
	ssh $node 'racadm set idrac.nic.selection 1'
	if [[ -n $(ssh $node 'racadm getniccfg' | grep Dedicated) ]]
	then
		echo success
	else
		echo FAILED!
	fi
done

echo "done. use output of /home/imstof/10g-dhcp to edit dhcp then reboot nodes"
