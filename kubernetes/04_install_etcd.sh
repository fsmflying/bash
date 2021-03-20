#!/bin/bash
#��װetcd��Ⱥ
IFS='
'
#����kubernetes�����ļ�·��
#ETCD_CONF_FILE=/usr/local/kubernetes/config/etcd.conf
#ETCD_CONF_FILE=/root/etcd.conf  #����
ETCD_CONF_FILE=/etc/etcd/etcd.conf
PEER_PORT=2380
ETCD_ACCESS_PORT=2379
i=1
ETCD_INITIAL_CLUSTER=#
#��ȡ��Ⱥ���н��
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

#����ǰ�װkubernetes��Ⱥ���鿴kubernetes����Ŀ¼�Ƿ����
if [ "${ETCD_CONF_FILE}" = "/usr/local/kubernetes/config/etcd.conf" ];then
  if [ ! -d "/usr/local/kubernetes/config" ];then
	mkdir -p /usr/local/kubernetes/config
  fi
fi
  
#���������������ļ�
i=1
for host in `cat master_hosts.txt`
do
  #��װetcd
  #ssh root@$host "yum install -y etcd"
  #���������ļ�
  #ssh root@$host "mv /etc/etcd/etcd.conf /etc/etcd/etcd.conf.bak"
  

  #�滻�����е�Ĭ�������ļ�
  if [ "${ETCD_CONF_FILE}" = "/usr/local/kubernetes/config/etcd.conf" ];then
    ssh root@$host "sed 's/\/etc\/etcd\/etcd.conf/\/usr\/local\/kubernetes\/config\/etcd.conf/g' /usr/lib/systemd/system/etcd.service"
  fi
  
  #����reload
  #ssh root@$host "systemctl daemon-reload"
  #��������Ϊ�Զ�����
  #ssh root@$host "systemctl enable etcd"
  #��������
  #ssh root@$host "systemctl start etcd"
  
  #���ɼ�Ⱥ�����ļ�
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
#���ɴӽ��������ļ�
for host in `cat node_hosts.txt`
do
  #��װetcd
  #ssh root@$host "yum install -y etcd"
  #���������ļ�
  #ssh root@$host "mv /etc/etcd/etcd.conf /etc/etcd/etcd.conf.bak"
  #���������ļ�
  #ssh root@$host "sed 's/\/etc\/etcd\/etcd.conf/\/usr\/local\/kubernetes\/config\/etcd.conf/g' /usr/lib/systemd/system/etcd.service"
  #����reload
  #ssh root@$host "systemctl daemon-reload"
  #��������Ϊ�Զ�����
  #ssh root@$host "systemctl enable etcd"
  #��������
  #ssh root@$host "systemctl start etcd"
  
  #���ɼ�Ⱥ�����ļ�
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
