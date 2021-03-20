#!/bin/bash
#安装etcd集群
IFS='
'
#设置kubernetes配置文件路径
#ETCD_CONF_FILE=/usr/local/kubernetes/config/etcd.conf
#ETCD_CONF_FILE=/root/etcd.conf  #测试
ETCD_CONF_FILE=/etc/etcd/etcd.conf
PEER_PORT=2380
ETCD_ACCESS_PORT=2379
i=1
ETCD_INITIAL_CLUSTER=#
#获取集群所有结点
for host in `cat master_hosts.txt`
do
  ETCD_INITIAL_CLUSTER=${ETCD_INITIAL_CLUSTER},node${i}=http://${host}:${PEER_PORT}
  let "i=i+1"
done

for host in `cat node_hosts.txt`
do 
  ETCD_INITIAL_CLUSTER=${ETCD_INITIAL_CLUSTER},node${i}=http://${host}:${PEER_PORT}
  let "i=i+1"
done
ETCD_INITIAL_CLUSTER=${ETCD_INITIAL_CLUSTER/\#\,node/node}
echo $ETCD_INITIAL_CLUSTER

#如果是安装kubernetes集群，查看kubernetes配置目录是否存在
if [ "${ETCD_CONF_FILE}" = "/usr/local/kubernetes/config/etcd.conf" ];then
  if [ ! -d "/usr/local/kubernetes/config" ];then
	mkdir -p /usr/local/kubernetes/config
  fi
fi
  
#生成主结点的配置文件
i=1
for host in `cat master_hosts.txt`
do
  #安装etcd
  #ssh root@$host "yum install -y etcd"
  #备份配置文件
  #ssh root@$host "mv /etc/etcd/etcd.conf /etc/etcd/etcd.conf.bak"
  

  #替换服务中的默认配置文件
  if [ "${ETCD_CONF_FILE}" = "/usr/local/kubernetes/config/etcd.conf" ];then
    ssh root@$host "sed 's/\/etc\/etcd\/etcd.conf/\/usr\/local\/kubernetes\/config\/etcd.conf/g' /usr/lib/systemd/system/etcd.service"
  fi
  
  #服务reload
  #ssh root@$host "systemctl daemon-reload"
  #服务配置为自动启动
  #ssh root@$host "systemctl enable etcd"
  #服务启动
  #ssh root@$host "systemctl start etcd"
  
  #生成集群配置文件
  ssh root@$host "echo '#[Member]' > ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_DATA_DIR=\"/var/lib/etcd/default.etcd\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_LISTEN_PEER_URLS=\"http://0.0.0.0:${PEER_PORT}\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_LISTEN_CLIENT_URLS=\"http://0.0.0.0:2379,http://0.0.0.0:4001\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_NAME=\"node${i}\"' >> ${ETCD_CONF_FILE}"
  
  ssh root@$host "echo '' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo '#[Clustering]' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://${host}:${PEER_PORT}\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_ADVERTISE_CLIENT_URLS=\"http://${host}:2379,http://${host}:4001\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_INITIAL_CLUSTER=\"${ETCD_INITIAL_CLUSTER}\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_INITIAL_CLUSTER_TOKEN=\"etcd-cluster\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_INITIAL_CLUSTER_STATE=\"new\"' >> ${ETCD_CONF_FILE}"

  let "i=i+1"
done
#生成从结点的配置文件
for host in `cat node_hosts.txt`
do
  #安装etcd
  #ssh root@$host "yum install -y etcd"
  #备份配置文件
  #ssh root@$host "mv /etc/etcd/etcd.conf /etc/etcd/etcd.conf.bak"
  #设置配置文件
  #ssh root@$host "sed 's/\/etc\/etcd\/etcd.conf/\/usr\/local\/kubernetes\/config\/etcd.conf/g' /usr/lib/systemd/system/etcd.service"
  #服务reload
  #ssh root@$host "systemctl daemon-reload"
  #服务配置为自动启动
  #ssh root@$host "systemctl enable etcd"
  #服务启动
  #ssh root@$host "systemctl start etcd"
  
  #生成集群配置文件
  ssh root@$host "echo '#[Member]' > ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_DATA_DIR=\"/var/lib/etcd/default.etcd\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_LISTEN_PEER_URLS=\"http://0.0.0.0:${PEER_PORT}\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_LISTEN_CLIENT_URLS=\"http://0.0.0.0:2379,http://0.0.0.0:4001\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_NAME=\"node${i}\"' >> ${ETCD_CONF_FILE}"
  
  ssh root@$host "echo '' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo '#[Clustering]' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://${host}:${PEER_PORT}\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_ADVERTISE_CLIENT_URLS=\"http://${host}:2379,http://${host}:4001\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_INITIAL_CLUSTER=\"${ETCD_INITIAL_CLUSTER}\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_INITIAL_CLUSTER_TOKEN=\"etcd-cluster\"' >> ${ETCD_CONF_FILE}"
  ssh root@$host "echo 'ETCD_INITIAL_CLUSTER_STATE=\"new\"' >> ${ETCD_CONF_FILE}"

  let "i=i+1"
done
