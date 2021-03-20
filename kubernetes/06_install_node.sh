#!/bin/bash

#KUBE_WORK_BASE=/usr/local/kubernetes
KUBE_WORK_BASE=/root/kubernetes       #for test
KUBE_BIN_DIR=${KUBE_WORK_BASE}/bin
KUBE_CONF_DIR=${KUBE_WORK_BASE}/config
#SYSTEMD_SERVICE_DIR=/usr/lib/systemd/system
SYSTEMD_SERVICE_DIR=/root/kubernetes   #for test
KUBE_API_PORT=8080
KUBE_DNS=192.168.2.0/24
ETCD_ACCESS_PORT=2379
CLUSTER_DNS=192.168.2.1
MASTER_HOST=`cat master_hosts.txt`
#获取集群所有结点
for host in `cat node_hosts.txt`
do
  #echo $host
  #echo $KUBE_BIN_DIR
  echo 
  #复制压缩包到master
  #scp kubernetes-server-linux-amd64.tar.gz root@$host:/root/
  #解压以及重命名
  #ssh root@${host} 'tar zxvf /root/kubernetes-node-linux-amd64.tar.gz -C /usr/local && mv /usr/local/kubernetes /usr/local/kubernetes-node'
  #创建kubenetes工作目录
  #if [ ! -d "${KUBE_WORK_BASE}" ];then
  #  mkdir -p ${KUBE_WORK_BASE}
  #fi
  #创建链接,先删除
  #ssh root@${host} "rm -rf ${KUBE_BIN_DIR}"
  #ssh root@${host} "ln -s /usr/local/kubernetes-node/node/bin ${KUBE_BIN_DIR}"
  #配置环境变量
  #ssh root@${host} "echo 'PATH=$PATH:${KUBE_BIN_DIR}' >> /etc/profile"
  
  #创建kubenetes工作目录
  #if [ ! -d "${KUBE_CONF_DIR}" ];then
  #  mkdir -p ${KUBE_CONF_DIR}
  #fi
  
  #生成kube-apiserver配置文件
  echo "$host:create file [${KUBE_CONF_DIR}/kubelet]"
  ssh root@${host} "echo '#启用日志标准错误' >  ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'KUBE_LOGTOSTDERR=\"--logtostderr=true\"' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo '#日志级别' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'KUBE_LOG_LEVEL=\"--v=4\"' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo '#Kubelet服务IP地址（自身IP）' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'NODE_ADDRESS=\"--address=${host}\"' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo '#Kubelet服务端口' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'NODE_PORT=\"--port=10250\"' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo '#自定义节点名称（自身IP）' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'NODE_HOSTNAME=\"--hostname-override=${host}\"' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo '#kubeconfig路径，指定连接API服务器' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'KUBELET_KUBECONFIG=\"--kubeconfig=${KUBE_CONF_DIR}/kubelet.kubeconfig\"' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo '#允许容器请求特权模式，默认false' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'KUBE_ALLOW_PRIV=\"--allow-privileged=false\"' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo '#DNS信息，跟上面给的地址段对应' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'KUBELET_DNS_IP=\"--cluster-dns=${CLUSTER_DNS}\"' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'KUBELET_DNS_DOMAIN=\"--cluster-domain=cluster.local\"' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo '#禁用使用Swap' >> ${KUBE_CONF_DIR}/kubelet"
  ssh root@${host} "echo 'KUBELET_SWAP=\"--fail-swap-on=false\"' >> ${KUBE_CONF_DIR}/kubelet"
  #生成kube-apiserver启动服务文件
  echo "$host:create file [${KUBE_CONF_DIR}/kubelet.kubeconfig]"
  ssh root@${host} "echo 'apiVersion: v1' >  ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo 'kind: Config' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo 'clusters:' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo '- cluster:' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo '    server: http://${MASTER_HOST}:${KUBE_API_PORT}' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo '  name: local' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo 'contexts:' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo '- context:' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo '    cluster: local' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo '  name: local' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"
  ssh root@${host} "echo 'current-context: local' >> ${KUBE_CONF_DIR}/kubelet.kubeconfig"

  #生成kubelet.service启动服务文件
  echo "$host:create file [${SYSTEMD_SERVICE_DIR}/kubelet.service]"
  ssh root@${host} "echo '[Unit]' >  ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo 'Description=Kubernetes Kubelet' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo 'After=docker.service' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo 'Requires=docker.service' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '[Service]' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo 'EnvironmentFile=-${KUBE_CONF_DIR}/kubelet' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo 'ExecStart=${KUBE_BIN_DIR}/kubelet \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${KUBE_LOGTOSTDERR} \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${KUBE_LOG_LEVEL} \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${NODE_ADDRESS} \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${NODE_PORT} \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${NODE_HOSTNAME} \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${KUBELET_KUBECONFIG} \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${KUBE_ALLOW_PRIV} \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${KUBELET_DNS_IP} \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${KUBELET_DNS_DOMAIN} \\' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '  \${KUBELET_SWAP}' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo 'Restart=on-failure' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo 'KillMode=process' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo '[Install]' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  ssh root@${host} "echo 'WantedBy=multi-user.target' >> ${SYSTEMD_SERVICE_DIR}/kubelet.service"
  
  #生成kube-proxy配置文件
  echo "$host:create file [${KUBE_CONF_DIR}/kube-proxy]"
  ssh root@${host} "echo '#启用日志标准错误' >  ${KUBE_CONF_DIR}/kube-proxy"
  ssh root@${host} "echo 'KUBE_LOGTOSTDERR=\"--logtostderr=true\"' >> ${KUBE_CONF_DIR}/kube-proxy"
  ssh root@${host} "echo '#日志级别' >> ${KUBE_CONF_DIR}/kube-proxy"
  ssh root@${host} "echo 'KUBE_LOG_LEVEL=\"--v=4\"' >> ${KUBE_CONF_DIR}/kube-proxy"
  ssh root@${host} "echo '#自定义节点名称（自身IP）' >> ${KUBE_CONF_DIR}/kube-proxy"
  ssh root@${host} "echo 'NODE_HOSTNAME=\"--hostname-override=${host}\"' >> ${KUBE_CONF_DIR}/kube-proxy"
  ssh root@${host} "echo '#API服务地址（MasterIP）' >> ${KUBE_CONF_DIR}/kube-proxy"
  ssh root@${host} "echo 'KUBE_MASTER=\"--master=http://${MASTER_HOST}:${KUBE_API_PORT}\"' >> ${KUBE_CONF_DIR}/kube-proxy"
  #生成kube-proxy启动服务文件
  echo "$host:create file [${SYSTEMD_SERVICE_DIR}/kube-proxy.service]"
  ssh root@${host} "echo '[Unit]' >  ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo 'Description=Kubernetes Proxy' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo 'After=network.target' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo '[Service]' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo 'EnvironmentFile=-/usr/local/kubernetes/config/kube-proxy' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo 'ExecStart=/usr/local/kubernetes/bin/kube-proxy \\' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo '  \${KUBE_LOGTOSTDERR} \\' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo '  \${KUBE_LOG_LEVEL} \\' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo '  \${NODE_HOSTNAME} \\' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo '  \${KUBE_MASTER}' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo 'Restart=on-failure' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo '[Install]' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"
  ssh root@${host} "echo 'WantedBy=multi-user.target' >> ${SYSTEMD_SERVICE_DIR}/kube-proxy.service"

  echo "$host:reload system services"
  #服务reload
  #ssh root@${host} "systemctl daemon-reload"
  #服务配置为自动启动
  #ssh root@$host "systemctl enable etcd"
  #服务启动
  #ssh root@$host "systemctl start etcd"
  let "i=i+1"
done



