#!/bin/bash

#!/bin/bash

for node in $(nodeset -e node[972-1014])
do
# send macs to file for dhcp
        echo "fetching mac for $node"
        N1MAC=$(ssh $node 'ip addr' | grep -A1 em1 | grep link | awk '{print $2}')
        MAC=$(ssh $node 'ip addr' | grep -A1 p3p1 | grep link | awk '{print $2}')
        echo "adding 10g-mac $MAC and nic1-mac $N1MAC to /home/imstof/10g-dhcp-972-1014"
        echo "host $node-10g {
     hardware ethernet $MAC;
     filename \"custom/uefi/elilo.efi\";
     fixed-address $node.inband.cluster;
}

#node $node {
#     hardware ethernet $N1MAC;
#     filename \"custom/uefi/elilo.efi\";
#     fixed-address $node.inband.cluster;
#}

" >> /home/imstof/10g-dhcp-972-1014
done
