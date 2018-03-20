#!/bin/bash

for node in $(nodeset -e node[1015-1029])
do
	echo "fetching mac for $node"
	N1MAC=$(ssh $node 'ip addr' | grep -A1 em1 | grep link | awk '{print $2}')
	MAC=$(ssh $node 'ip addr' | grep -A1 p3p1 | grep link | awk '{print $2}')
	echo "adding 10g-mac $MAC and nic1-mac $N1MAC to /home/imstof/10g-dhcp"
	echo "host $node-10g {
     hardware ethernet $MAC;
     filename \"custom/pxelinux.0\";
     fixed-address $node.inband.cluster;
}

#node $node {
#     hardware ethernet $N1MAC;
#     filename \"custom/pxelinux.0\";
#     fixed-address $node.inband.cluster;
#}

" >> /home/imstof/10g-dhcp

	echo "setting ifcfg-p3p1 for $node"
	ssh $node "sed -i 's/BOOT=no/BOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-p3p1"
	if [[ -n $(ssh $node 'cat /etc/sysconfig/network-scripts/ifcfg-p3p1' | grep BOOT=yes) ]]
	then
		echo success
	else
		echo FAILED!
	fi

	echo "setting dedicated ipmi port for $node"
	ssh $node 'racadm set idrac.nic.selection 1'
done
