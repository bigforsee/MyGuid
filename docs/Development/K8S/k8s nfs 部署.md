# k8s  nfs 部署
安装NFS

### master节点安装nfs
```shell
yum -y install nfs-utils
```

### 创建nfs目录

```shell
mkdir -p /nfs/data/
```

### 修改权限
```shell
 chmod -R 777 /nfs/data
```

#### 编辑export文件,这个文件就是nfs默认的配置文件
```shell
vim /etc/exports
```

```shell
/nfs/data *(rw,no_root_squash,sync)
```

no_root_squash 这个是权限的 

#### 配置生效

```shell
exportfs -r
```

### 查看生效

```shell
exportfs
```

```text
/nfs/data 
```

 

## 启动rpcbind、nfs服务
```hell
systemctl restart rpcbind && systemctl enable rpcbind
systemctl restart nfs && systemctl enable nfs
```


输出：Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.

### 查看 RPC 服务的注册状况

```hell
 rpcinfo -p localhost
 program vers proto   port  service
 100000    4   tcp    111  portmapper
 100000    3   tcp    111  portmapper
 100000    2   tcp    111  portmapper
 100000    4   udp    111  portmapper |
```





### showmount测试

```hell
showmount -e 192.168.0.66
 Export list for 192.168.0.66:
 /nfs/data *
```

3.2创建PV
创建前我们先在master节点 mkdir /nfs/data/nginx 创建出一个nginx子目录供pv使用

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
  namespace: default
  labels:
    pv: nfs-pv
spec:
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs
  nfs:  
    server: 192.168.0.66
    path: "/nfs/data/nginx"   #NFS目录，需要该目录在NFS上存在
```




然后执行创建

```hell
kubectl apply -f pv.yaml 
```

persistentvolume/nfs-pv created

```hell
 kubectl get pv
```

NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
nfs-pv   100Mi      RWX            Retain           Available                                   7s

**PV 的访问模式（accessModes）有三种：**

ReadWriteOnce（RWO）：是最基本的方式，可读可写，但只支持被单个 Pod 挂载。
ReadOnlyMany（ROX）：可以以只读的方式被多个 Pod 挂载。
ReadWriteMany（RWX）：这种存储可以以读写的方式被多个 Pod 共享。

**PV 的回收策略**（persistentVolumeReclaimPolicy，即 PVC 释放卷的时候 PV 该如何操作）也有三种：

Retain，不清理, 保留 Volume（需要手动清理）
Recycle，删除数据，即 rm -rf /volume/*（只有 NFS 和 HostPath 支持）
Delete，删除存储资源，比如删除 AWS EBS 卷（只有 AWS EBS, GCE PD, Azure Disk 和 Cinder 支持）
PVC释放卷是指用户删除一个PVC对象时，那么与该PVC对象绑定的PV就会被释放。

**PersistentVolume有四种状态：**
Available: 可用状态
Bound: 绑定到PVC
Released: PVC被删掉，但是尚未回收
Failed : 自动回收失败

### 3.3创建PVC

```hell
vim pvc.yaml
```

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Mi  #容量
  selector:
    matchLabels:
      pv: nfs-pv   #关联pv 的label,key/value要一致
```


执行创建命令

```hell
kubectl apply -f pvc.yaml 
```

persistentvolumeclaim/nfs-pvc created

```hell
kubectl get pvc
```

NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
nfs-pvc   Bound    nfs-pv   100Mi      RWX 

```hell
kubectl get pv
```

NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   REASON   AGE
nfs-pv   100Mi      RWX            Retain           Bound    default/nfs-pvc
此时pv状态已经从Available变成Bound状态。

### 3.4 创建pod并使用pvc存储资源

```hell
vim nginx.yaml
```

#deploy

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-nginx
  namespace: default
spec:
  selector:
    matchLabels:
      app: nfs-nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nfs-nginx
    spec:
      containers:
      - name: nginx-web
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: html
      volumes:
      - name: html
        persistentVolumeClaim:
        claimName: nfs-pvc
```

 #我们用nginx镜像进行验证，将html目录映射到nfs目录中

#service

```yml
apiVersion: v1
kind: Service
metadata:
  name: nfs-nginx
  namespace: default
spec:
  type: NodePort
  ports:

  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 31681
    selector:
    app: nfs-nginx
```

  - 创建pod容器
    
    ```shell
    kubectl apply -f nginx.yaml
    kubectl get pods  -o wide
    ```
    
    ```shell
    NAME                         READY   STATUS    RESTARTS   AGE   IP            NODE        NOMINATED NODE   READINESS GATES
    nfs-nginx-7695b95db6-l74zx   1/1     Running   0          12s   10.244.2.93   k8s-node1   <none>           <none>
    nfs-nginx-7695b95db6-qcqp8   1/1     Running   0          12s   10.244.1.22   k8s-node2   <none>           <none>
    ```
    
    

如果kubectl describe pods xxx 发现有如下报错，则在节点服务器上安装nfs-unitls

Output: Running scope as unit run-20005.scope.
mount: wrong fs type, bad option, bad superblock on 192.168.0.66:/nfs/data/nginx,
       missing codepage or helper program, or other error
各节点安装并启用nfs

```shell
yum install nfs-utils
systemctl start nfs & systemctl enable nfs
systemctl start rpcbind & systemctl enable rpcbind
```



3.5验证
3.5.1直接放文件到NFS的/nfs/data/nginx目录
我们在/nfs/data/nginx目录创建了一个1.html文件


<html>
<body>Test01</body>
</html>





## NFS 自动挂载

如果没有安装就先安装

```shell
yum -y install nfs-utils
```

测试是否可用

```shell
showmount -e 192.168.56.160
```

脚本自动[挂载]

```shell
mkdir -p /mnt/kubernetes
vi /usr/local/sbin/nfsboot.sh
```

```shell
#!/bin/bash

## This is NFS disk automount shell script

echo "NFS启动时间点:$(date +"%F %T")" >>nfs.log;

val=`df -h|grep website | wc -l`

if [ $val -eq 1 ]

then

          echo  "NFS目录/tmp/website已经挂载，无需再挂" >> nfs.log;

else 

mount  -o vers=3   192.168.56.160:/ifs/kubernetes/ /mnt/kubernetes/

echo  "NFS目录/tmp/website挂载成功" >> nfs.log;

exit

fi

echo "执行完毕" >> nfs.log
```

脚本赋权

```shell
chmod +x /usr/local/sbin/nfsboot.sh
```

2.`将脚本加入开机自启动中`

```shell
echo "/usr/local/sbin/nfsboot.sh" >>/etc/rc.d/rc.local
```

3.'赋权'

```shell
chmod +x     /etc/rc.d/rc.local

```



## minio 部署

### 分布式部署

```shell
helm install minio \
  --namespace minio --create-namespace \
  --set accessKey=minio,secretKey=minio123 \
  --set mode=distributed \
  --set replicas=4 \
  --set service.type=NodePort \
  --set persistence.size=10Gi \
  --set persistence.storageClass=nfs-storage \
  minio/minio
```



单独部署

```shell
helm install minio \
  --namespace minio --create-namespace \
  --set accessKey=minio,secretKey=minio123 \
  --set mode=standalone \
  --set service.type=NodePort \
  --set persistence.enabled=true \
  --set persistence.size=10Gi \
  --set persistence.storageClass=local \
  minio/minio

```

