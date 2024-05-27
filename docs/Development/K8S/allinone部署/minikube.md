# Minikube 安装手册

[minikube 官网](https://minikube.sigs.k8s.io/docs/start/)



## Linux 下载minikube

```shell
#下载最新版本
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
#查看安装版本
minikube version
```



## 安装cri-docker

由于1.24以及更高版本不支持docker所以安装cri-docker

- 安装wget

  ```shell
  yum install -y wget
  ```

- 下载 `cri-docker`

  ```shell
  wget  https://ghproxy.com/https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.5/cri-dockerd-0.2.5.amd64.tgz
  ```

  

- 解压cri-docker

  ```shell
  tar xvf cri-dockerd-0.2.5.amd64.tgz 
  cp cri-dockerd/cri-dockerd  /usr/bin/
  chmod +x /usr/bin/cri-dockerd
  ```

  

- 写入启动配置文件

  ```shell
  cat >  /usr/lib/systemd/system/cri-docker.service <<EOF
  [Unit]
  Description=CRI Interface for Docker Application Container Engine
  Documentation=https://docs.mirantis.com
  After=network-online.target firewalld.service docker.service
  Wants=network-online.target
  Requires=cri-docker.socket
   
   
  [Service]
  Type=notify
  ExecStart=/usr/bin/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.7
  ExecReload=/bin/kill -s HUP $MAINPID
  TimeoutSec=0
  RestartSec=2
  Restart=always
   
   
  StartLimitBurst=3
   
   
  StartLimitInterval=60s
   
   
  LimitNOFILE=infinity
  LimitNPROC=infinity
  LimitCORE=infinity
   
   
  TasksMax=infinity
  Delegate=yes
  KillMode=process
   
   
  [Install]
  WantedBy=multi-user.target
  EOF
  ```

  

- 写入socket配置文件

  ```shell
  cat > /usr/lib/systemd/system/cri-docker.socket <<EOF
  [Unit]
  Description=CRI Docker Socket for the API
  PartOf=cri-docker.service
   
   
  [Socket]
  ListenStream=%t/cri-dockerd.sock
  SocketMode=0660
  SocketUser=root
  SocketGroup=docker
   
   
  [Install]
  WantedBy=sockets.target
  EOF
  ```

  

- 进行启动cri-docker

  ```shell
  systemctl daemon-reload 
  systemctl enable cri-docker --now
  ```

- 如果不用 docker 用户，只需要在初始化集群时加上 minikube start `--driver=none`

```shell
 --vm-driver=none
```



## 启动安装 minikube

```shell
minikube start  --driver=none --registry-mirror=https://registry.docker-cn.com  --image-mirror-country cn
```





- 如果报 `X Exiting due to GUEST_MISSING_CONNTRACK: Sorry, Kubernetes 1.20.2 requires conntrack to be installed in root's path`，则需要安装 construct。

  ```shell
  yum install conntrack
  ```

- 错误信息`Failed to enable unit: Unit file cri-docker.socket does not exist`

  ````shell
  cri-dockerd --version
  ````

   如果没有版本安装 `cri-docer` [安装的问题](https://www.jianshu.com/p/2eb952ffe89b)



- 错误信息：`Exiting due to RUNTIME_ENABLE: Temporary Error: sudo crictl version: exit status 1`

- [crictl官网安装步骤](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fkubernetes-sigs%2Fcri-tools)

  ```shell
  VERSION="v1.24.1"
  
  wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
  
  sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
  
  rm -f crictl-$VERSION-linux-amd64.tar.gz
  
  ```

  

