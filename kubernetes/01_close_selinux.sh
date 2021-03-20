#!/bin/bash

IFS='
'

#关闭selinux
#sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
for host in `cat master_hosts.txt`
do
  ssh root@$host "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"
done

for host in `cat node_hosts.txt`
do
  ssh root@$host "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"
done
