## 1.新增虚拟机

>  `找到k8s目录,根据需求修改Vagrantfile内的参数`

```cmd
vagrant up 
```

```cmd
Vagrant ssh k8s-node1 
su root
```

`   密码为vagrant`

```cmd
vi /etc/ssh/sshd_config
查找
/p PasswordAuthentication
修改 输入I
PermitRootLogin yes
PasswordAuthentication yes
重启服务
service sshd restart
```

`关机后设置->网络->选择NET网络->高级选项刷新MAC地址保存,启动虚拟机`

 `现在可以使用xshell进行连接 `

## 2.设置linux环境

1.`关闭防火墙`

```shell
systemctl stop firewalld
systemctl disable firewalld
```

`关闭selinux    `

```shell
sed -i 's/enforcing/disabled/' /etc/selinux/config
setenforce 0
```

2.`关闭swap  `

```shell
sed -ri 's/.*swap.*/#&/' /etc/fstab
swapoff -a
```

3.`设置hosts 参考内容`

```shell
[root@k8s-node3 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.1.1 k8s-node3 
10.0.2.5 k8s-node1
10.0.2.4 k8s-node2
10.0.2.15 k8s-node3

# kubekey hosts BEGIN
10.0.2.5  k8s-node1.cluster.local k8s-node1
10.0.2.4  k8s-node2.cluster.local k8s-node2
10.0.2.15  k8s-node3.cluster.local k8s-node3
10.0.2.5  lb.kubesphere.local
# kubekey hosts END

```



4.`将桥接的IPV4流量传递到iptables的链：`

```shell
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
```

应用规则

```shell
sysctl --system
```

5.`安装docker、kubeadm、kubelet、kubectl  `

查看mastr 的 docker版本： 尽可能安装一致 

    docker --version

### 1.安装docker
1.卸载之前安装的docker  

```shell
sudo yum remove docker \
              docker-client \
              docker-client-latest \
              docker-common \
              docker-latest \
              docker-latest-logrotate \
              docker-logrotate \
              docker-engine
```


2.安装Docker -CE   

```shell
yum install -y  yum-utils \
device-mapper-persistent-data \
lvm2
#方镜源*
sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo
```

###  **阿里源**

```shell
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

```shell
sudo yum -y install docker-ce docker-ce-cli containerd.io  
```



3.配置镜像加速  

    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
    {
        "registry-mirrors": ["https://ke9h1pt4.mirror.aliyuncs.com"]
    }
    EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
使用`docker ps`查看。  
使用`docker info|grep "Registry Mirrors" -A 1`查看镜像。

4.启动Docker && 设置docker开机启动

    systemctl enable docker

### 2.添加阿里与Yum源
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
    EOF

### 3.安装kubeadm，kubelet和kubectl
    yum list|grep kube

安装 

```shell
yum install -y kubelet-1.17.9 kubeadm-1.17.9 kubectl-1.17.9
```

配置开机启动，其他东西没配置还启动不起来  

    systemctl enable kubelet && systemctl start kubelet  
查看kubelet的状态：

    systemctl status kubelet

查看kubelet版本：  

    kubelet --version

方式二：

在node节点配置kubectl、kubeadm、kubelet 将master中的kubernetes.repo复制到其他节点![在这里插入图片描述](https://img-blog.csdnimg.cn/20190919091246923.png)

```shell
cat /etc/yum.repos.d/kubernetes.repo
```



安装kubectl、kubeadm、kubelet

```shell
yum install -y kubeadm kubelet
```





### **设置环境变量**

从master节点拷贝 /etc/kubernetes/admin.conf 到 node /etc/kubernetes/下面

```shell
scp -r k8s-node1:/etc/kubernetes/admin.conf  /etc/kubernetes/
```



具体根据情况，此处记录linux设置该环境变量
方式一：编辑文件设置

​	   在底部增加新的环境变量

```shel
vi /etc/profile
```

```shell
 export KUBECONFIG=/etc/kubernetes/admin.conf
```

方式二:直接追加文件内容

```shell
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profile
```

```shell
scp -r k8s-node1:/etc/cni /etc/cni
```



### **使生效**

```shell
	source /etc/profile
```



```csharp
#在主节点上执行以下命令，获取加入集群命令
```

```shell
 kubeadm token create --print-join-command --ttl 0
```

`#然后将打印出来的命令在新节点上执行即可`

```shell
kubectl get nodes
```