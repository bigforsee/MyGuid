## 3、设置linux环境（三个环境都执行） 

关闭防火墙
    systemctl stop firewalld
    systemctl disable firewalld

关闭selinux    

    sed -i 's/enforcing/disabled/' /etc/selinux/config
    setenforce 0

关闭swap  

    sed -ri 's/.*swap.*/#&/' /etc/fstab

  添加主机名与IP对应关系：  
  使用`hostname`查看主机名，可使用下方命令进行修改

    hostnamectl set-hostname <newhostname>

使用自己的 网卡地址进行配置

    vi /etc/hosts
    10.0.2.15 k8s-node1
    10.0.2.4 k8s-node2
    10.0.2.5 k8s-node3
将桥接的IPV4流量传递到iptables的链：

    cat > /etc/sysctl.d/k8s.conf <<EOF
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOF
  应用规则：

    sysctl --system


### 1.安装docker
1.卸载之前安装的docker  

    sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine


2.安装Docker -CE   

    yum install -y  yum-utils \
    device-mapper-persistent-data \
    lvm2
    
    sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
    
    sudo yum -y install docker-ce docker-ce-cli containerd.io

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

   systemctl stop firewalld
    systemctl status firewalld
****
    getenforce
****
    swapoff -a
    echo "vm.swappiness=0" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf
****
    sed -i 's$/dev/mapper/centos-swap$#/dev/mapper/centos-swap$g' /etc/fstab
    free -m
****
    yum -y install chrony
****
    sed -i.bak '3,6d' /etc/chrony.conf && sed -i '3cserver ntp1.aliyun.com iburst' \
    /etc/chrony.conf
****
    systemctl start chronyd && systemctl enable chronyd 
****
    cat >/etc/sysctl.d/k8s.conf <<EOF
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.ipv4.ip_forward = 1
    EOF
****
    modprobe br_netfilter && sysctl -p /etc/sysctl.d/k8s.conf
****
    cat > /etc/sysconfig/modules/ipvs.modules <<EOF
    #!/bin/bash
    modprobe -- ip_vs
    modprobe -- ip_vs_rr
    modprobe -- ip_vs_wrr
    modprobe -- ip_vs_sh
    modprobe -- nf_conntrack_ipv4
    EOF
****
    chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
****
    yum -y install ipset ipvsadm
****
    yum install -y ebtables socat ipset conntrack
****
    yum install -y yum-utils
****

	 cat > /etc/docker/daemon.json <<EOF
	{
	    "registry-mirrors": ["https://gqk8w9va.mirror.aliyuncs.com"]
	}
	EOF
****
    sed -i.bak "s#^ExecStart=/usr/bin/dockerd.*#ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd#g" /usr/lib/systemd/system/docker.service
****
    systemctl daemon-reload
    systemctl restart docker


****
参考：
https://kubesphere.com.cn/docs/installing-on-linux/high-availability-configurations/ha-configuration/

先执行以下命令以确保您从正确的区域下载 KubeKey。

    export KKZONE=cn

****
执行以下命令下载 KubeKey：
    
    curl -sfL https://get-kk.kubesphere.io | VERSION=v1.1.1 sh -
****
为 kk 添加可执行权限：

    chmod +x kk
****
创建包含默认配置的示例配置文件。这里使用 Kubernetes v1.20.4 作为示例。
    
    ./kk create config --with-kubesphere v3.1.1 --with-kubernetes v1.20.4

配置负载均衡器


    controlPlaneEndpoint:
        domain: lb.kubesphere.local
        address: "192.168.0.xx"
        port: "6443"  

最终修改配置如下：

    apiVersion: kubekey.kubesphere.io/v1alpha1
    kind: Cluster
    metadata:
    name: sample
    spec:
    hosts:
    - {name: k8s-master1, address: 10.30.30.167, internalAddress: 10.30.30.167, user: root, password: docker123}
    - {name: k8s-master2, address: 10.30.30.168, internalAddress: 10.30.30.168, user: root, password: docker123}
    - {name: k8s-master3, address: 10.30.30.169, internalAddress: 10.30.30.169, user: root, password: docker123}
    - {name: k8s-node173, address: 10.30.30.173, internalAddress: 10.30.30.173, user: root, password: admin@123456}
    roleGroups:
        etcd:
        - k8s-master1
        - k8s-master2
        - k8s-master3
        master:
        - k8s-master1
        - k8s-master2
        - k8s-master3
        worker:
        - k8s-node173
    controlPlaneEndpoint:
        domain: lb.kubesphere.local
        address: "10.2.2.252"
        port: 6443
    kubernetes:
        version: v1.20.6
        imageRepo: kubesphere
        clusterName: cluster.local
        maxPods: 600
    network:
        plugin: calico
        kubePodsCIDR: 10.233.64.0/18
        kubeServiceCIDR: 10.233.0.0/18
    registry:
        registryMirrors: []
        insecureRegistries: []
    addons: []


安装集群，等待安装完成

    ./kk create cluster -f config-sample.yaml

Docker123

其他命令参考
    https://github.com/kubesphere/kubekey/blob/master/README_zh-CN.md





Console: http://10.0.2.14:30880
Account: admin
Password: P@88w0rd



NFS 持久化存储 

- 每台机器上都需要安装服务

```shell
yum -y install nfs-utils
```

新建文件 deployment.yaml 需要修改NFS服务IP和共享文件夹名

``````yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-client-provisioner
  labels:
    app: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 192.168.56.159
            - name: NFS_PATH
              value: /mnt/kubernetes
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.56.159
            path: /mnt/kubernetes
``````

在给操作权限 rabc.yaml

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io

```

最后在新建storageclass.yaml 并设置成默认的存储

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "false"
```



应用该配置

```shell
kubectl create -f .
```



# 基于 `helm` 部署 `harbor` 

```shell
helm repo add harbor https://helm.goharbor.io
helm install harbor harbor/harbor --version 1.11.0
```



# ingress 部署

```shell
helm repo add k8s-as-helm https://ameijer.github.io/k8s-as-helm
helm install ingress k8s-as-helm/ingress --version 1.0.3
```



# Grafana部署

```shell
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana --version 6.50.7
```



# Prometheus部署

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus --version 19.3.3
```



# 搭建 EFK 日志系统

创建 `Elasticsearch` 集群

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install elasticsearch bitnami/elasticsearch --version 19.5.10
helm install fluentd bitnami/fluentd --version 5.5.14
helm install kibana bitnami/kibana --version 10.2.14
```



# 基于 Jenkins 的 CI/CD 



```shell
kubectl create nagespace kube-ops
```

新建 `jenkins2.yaml`  新建名称空间

```shell
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins2
  namespace: kube-ops
spec: 
  selector:
    matchLabels:
      app: jenkins2
  template:
    metadata:
      labels:
        app: jenkins2
    spec:
      terminationGracePeriodSeconds: 10
      serviceAccount: jenkins2
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
          name: web
          protocol: TCP
        - containerPort: 50000
          name: agent
          protocol: TCP
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 60
          timeoutSeconds: 5
          failureThreshold: 12
        readinessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 60
          timeoutSeconds: 5
          failureThreshold: 12
        volumeMounts:
        - name: jenkinshome
          subPath: jenkins2
          mountPath: /var/jenkins_home
      securityContext:
        fsGroup: 1000
      volumes:
      - name: jenkinshome
        persistentVolumeClaim:
          claimName: opspvc

---
apiVersion: v1
kind: Service
metadata:
  name: jenkins2
  namespace: kube-ops
  labels:
    app: jenkins2
spec:
  selector:
    app: jenkins2
  type: NodePort
  ports:
  - name: web
    port: 8080
    targetPort: web
    nodePort: 30002
  - name: agent
    port: 50000
    targetPort: agent
```

由于我们使用了自动创建PVC和PV这里就不创建PV了

建立权限控制 rbac.yaml

```shell
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins2
  namespace: kube-ops

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: jenkins2
rules:
  - apiGroups: ["extensions", "apps"]
    resources: ["deployments"]
    verbs: ["create", "delete", "get", "list", "watch", "patch", "update"]
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["create", "delete", "get", "list", "watch", "patch", "update"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["create","delete","get","list","patch","update","watch"]
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["create","delete","get","list","patch","update","watch"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get","list","watch"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get"]

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: jenkins2
  namespace: kube-ops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: jenkins2
subjects:
  - kind: ServiceAccount
    name: jenkins2
    namespace: kube-ops
```



```shell
kubectl create -f jenkins2.yaml
kubectl create -f jenkins2.yaml
```

