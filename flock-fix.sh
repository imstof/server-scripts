#!/bin/bash

#already ran sed across nodes
#sed -i 's/localflock/flock/' /etc/fstab
umount /c3ddb/lustre/cstor01
umount -a -t lustre
mount -a -t lustre
mount /c3ddb/lustre/cstor01

#check if any did not change
echo $(mount | grep localflock)
