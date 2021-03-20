#!/bin/bash

KUBE_WORK_BASE=/usr/local/kubernetes
#KUBE_WORK_BASE=/root/kubernetes       #for test
KUBE_BIN_DIR=${KUBE_WORK_BASE}/bin
KUBE_CONF_DIR=${KUBE_WORK_BASE}/config
SYSTEMD_SERVICE_DIR=/usr/lib/systemd/system
#SYSTEMD_SERVICE_DIR=/root/kubernetes   #for test
KUBE_API_PORT=8080
KUBE_DNS=192.168.2.0/24
ETCD_ACCESS_PORT=2379
#获取集群所有结点
for host in `cat master_hosts.txt`
do
  echo $host
  echo $KUBE_BIN_DIR
  echo 
  #复制压缩包到master
  #scp kubernetes-server-linux-amd64.tar.gz root@$host:/root/
  #解压以及重命名
  #ssh root@${host} 'tar zxvf /root/kubernetes-server-linux-amd64.tar.gz -C /usr/local && mv /usr/local/kubernetes /usr/local/kubernetes-server'
  #创建kubenetes工作目录
  #if [ ! -d "${KUBE_WORK_BASE}" ];then
  #  mkdir -p ${KUBE_WORK_BASE}
  #fi
  #创建链接,先删除
  #ssh root@${host} "rm -rf ${KUBE_BIN_DIR}"
  #ssh root@${host} "ln -s /usr/local/kubernetes-server/server/bin ${KUBE_BIN_DIR}"
  #配置环境变量
  #ssh root@${host} "echo 'PATH=$PATH:${KUBE_BIN_DIR}' >> /etc/profile"
  
  #创建kubenetes工作目录
  #if [ ! -d "${KUBE_CONF_DIR}" ];then
  #  mkdir -p ${KUBE_CONF_DIR}
  #fi
  
  #生成kube-apiserver配置文件
  echo "$host:create file [${KUBE_CONF_DIR}/kube-apiserver]"
  ssh root@${host} "echo '#启用日志标准错误' >  ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo 'KUBE_LOGTOSTDERR=\"--logtostderr=true\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#日志级别' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo 'KUBE_LOG_LEVEL=\"--v=4\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#Etcd服务地址' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo 'KUBE_ETCD_SERVERS=\"--etcd-servers=http://${host}:${ETCD_ACCESS_PORT}\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#API服务监听地址' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo 'KUBE_API_ADDRESS=\"--insecure-bind-address=0.0.0.0\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#API服务监听端口' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo 'KUBE_API_PORT=\"--insecure-port=${KUBE_API_PORT}\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#KUBE_API_PORT=\"--secure-port=443\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#对集群中成员提供API服务地址' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo 'KUBE_ADVERTISE_ADDR=\"--advertise-address=${host}\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#允许容器请求特权模式，默认false' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo 'KUBE_ALLOW_PRIV=\"--allow-privileged=false\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#集群分配的IP范围，自定义但是要跟后面的kubelet（服务节点）的配置DNS在一个区间' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo 'KUBE_SERVICE_ADDRESSES=\"--service-cluster-ip-range=${KUBE_DNS}\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#基于HTTP BASE的安全验证' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#KUBE_AUTH_OPTIONS=\"--basic-auth-file=${KUBE_CONF_DIR}/basic_auth_file\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '#KUBE_AUTH_OPTIONS=\"--token-auth-file=${KUBE_CONF_DIR}/token_auth_file\"' >> ${KUBE_CONF_DIR}/kube-apiserver"
  ssh root@${host} "echo '' >> ${KUBE_CONF_DIR}/kube-apiserver"
  #生成kube-apiserver启动服务文件
  echo "$host:create file [${SYSTEMD_SERVICE_DIR}/kube-apiserver.service]"
  ssh root@${host} "echo '[Unit]' >  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo 'Description=Kubernetes API Server' >> ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo 'Documentation=https://github.com/kubernetes/kubernetes' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '[Service]' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo 'EnvironmentFile=-${KUBE_CONF_DIR}/kube-apiserver' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo 'ExecStart=${KUBE_BIN_DIR}/kube-apiserver \\' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '  \${KUBE_LOGTOSTDERR} \\' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '  \${KUBE_LOG_LEVEL} \\' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '  \${KUBE_ETCD_SERVERS} \\' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '  \${KUBE_API_ADDRESS} \\' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '  \${KUBE_API_PORT} \\' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '  \${KUBE_ADVERTISE_ADDR} \\' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '  \${KUBE_ALLOW_PRIV} \\' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '  \${KUBE_SERVICE_ADDRESSES} \\' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '  \${KUBE_AUTH_OPTIONS}' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo 'Restart=on-failure' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo '[Install]' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"
  ssh root@${host} "echo 'WantedBy=multi-user.target' >>  ${SYSTEMD_SERVICE_DIR}/kube-apiserver.service"

  #生成kube-controller-manager配置文件
  echo "$host:create file [${KUBE_CONF_DIR}/kube-controller-manager]"
  ssh root@${host} "echo 'KUBE_LOGTOSTDERR=\"--logtostderr=true\"' >  ${KUBE_CONF_DIR}/kube-controller-manager"
  ssh root@${host} "echo 'KUBE_LOG_LEVEL=\"--v=4\"' >> ${KUBE_CONF_DIR}/kube-controller-manager"
  ssh root@${host} "echo 'KUBE_MASTER=\"--master=${host}:${KUBE_API_PORT}\"' >> ${KUBE_CONF_DIR}/kube-controller-manager"
  #生成kube-controller-manager启动服务文件
  echo "$host:create file [${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service]"
  ssh root@${host} "echo '[Unit]' >  ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo 'Description=Kubernetes Controller Manager' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo 'Documentation=https://github.com/kubernetes/kubernetes' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo '[Service]' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo 'EnvironmentFile=-${KUBE_CONF_DIR}/kube-controller-manager' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo 'ExecStart=${KUBE_BIN_DIR}/kube-controller-manager \\' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo '  \${KUBE_LOGTOSTDERR} \\' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo '  \${KUBE_LOG_LEVEL} \\' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo '  \${KUBE_MASTER} \\' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo '  \${KUBE_LEADER_ELECT}' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo 'Restart=on-failure' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo '[Install]' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  ssh root@${host} "echo 'WantedBy=multi-user.target' >> ${SYSTEMD_SERVICE_DIR}/kube-controller-manager.service"
  
  #生成kube-scheduler配置文件
  echo "$host:create file [${KUBE_CONF_DIR}/kube-scheduler]"
  ssh root@${host} "echo 'KUBE_LOGTOSTDERR=\"--logtostderr=true\"' >  ${KUBE_CONF_DIR}/kube-scheduler"
  ssh root@${host} "echo 'KUBE_LOG_LEVEL=\"--v=4\"' >> ${KUBE_CONF_DIR}/kube-scheduler"
  ssh root@${host} "echo 'KUBE_MASTER=\"--master=${host}:${KUBE_API_PORT}\"' >> ${KUBE_CONF_DIR}/kube-scheduler"
  ssh root@${host} "echo 'KUBE_LEADER_ELECT=\"--leader-elect\"' >> ${KUBE_CONF_DIR}/kube-scheduler"
  #生成kube-scheduler启动服务文件
  echo "$host:create file [${SYSTEMD_SERVICE_DIR}/kube-scheduler.service]"
  ssh root@${host} "echo '[Unit]' >  ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo 'Description=Kubernetes Scheduler' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo 'Documentation=https://github.com/kubernetes/kubernetes' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo '[Service]' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo 'EnvironmentFile=-${KUBE_CONF_DIR}/kube-scheduler' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo 'ExecStart=${KUBE_BIN_DIR}/kube-scheduler \\' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo '  \${KUBE_LOGTOSTDERR} \\' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo '  \${KUBE_LOG_LEVEL} \\' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo '  \${KUBE_MASTER} \\' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo '  \${KUBE_LEADER_ELECT}' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo 'Restart=on-failure' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo '[Install]' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"
  ssh root@${host} "echo 'WantedBy=multi-user.target' >> ${SYSTEMD_SERVICE_DIR}/kube-scheduler.service"

  echo "$host:reload system services"
  #服务reload
  #ssh root@${host} "systemctl daemon-reload"
  #服务配置为自动启动
  #ssh root@$host "systemctl enable etcd"
  #服务启动
  #ssh root@$host "systemctl start etcd"
  let "i=i+1"
done



