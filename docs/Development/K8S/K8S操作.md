# K8S操作

## node操作

> 1.停止调度`服务

​		个别时候，我们需要对我们cluster中的node进行维护，例如重启，我们如果不希望客户的pod手动影响，我们可以先drain这个node， 意思就是把上边的pod都迁移到其他node上，这样你重启这个机器就影响任何pod了

```shell
kubectl drain node-1
```

当然，我们平时也可以标记一个node不可用

```she
kubectl cordorn node-1
```

​		注意，cordorn命令执行后，node-1上的pod并不受影响，但是新的pod不会被schedule到这个node-1了





# calico

## 添加IP pool

**1. 下载二进制文件**

```shell
wget https://github.com/projectcalico/calicoctl/releases/download/v3.5.4/calicoctl -O /usr/bin/calicoctl
chmod +x /usr/bin/calicoctl
```

**2. 添加calicoctl配置文件**

calicoctl通过读写calico的数据存储系统（datastore）进行查看或者其他各类管理操作，通常，它需要提供认证信息经由相应的数据存储完成认证。在使用Kubernetes API数据存储时，需要使用类似kubectl的认证信息完成认证。它可以通过环境变量声明的DATASTORE_TYPE和KUBECONFIG接入集群，例如以下命令格式运行calicoctl

```shell
DATASTORE_TYPE=kubernetes KUBECONFIG=~/.kube/config calicoctl get nodes
```

也可以直接将认证信息等保存于配置文件中，calicoctl默认加载 /etc/calico/calicoctl.cfg 配置文件读取配置信息，如下所示：

```shell
vi /etc/calico/calicoctl.cfg
```

```yaml
apiVersion: projectcalico.org/v3
kind: CalicoAPIConfig
metadata:
spec:
  datastoreType: "kubernetes"
  kubeconfig: "/root/.kube/config"
```



```shell
calicoctl get nodes
NAME         
k8s-master   
k8s-node1    
k8s-node2  
```

**建立OA的IP pool**

```sell
vi ippool-oa.yaml
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: ecology-pool
spec:
  blockSize: 31
  cidr: 10.234.0.0/31
  ipipMode: Never
  natOutgoing: true

```

```shell
DATASTORE_TYPE=kubernetes KUBECONFIG=~/.kube/config calicoctl create -f ippool-oa.yaml 
```

**在OA的yaml里面 annotations:添加**

```ya
        cni.projectcalico.org/ipv4pools: '["ecology-pool"]'
```



# 创建资源清单输出到文件

```shell
kubectl create deployment web --image=nginx -o yaml --dry-run > hello.yaml
```





```shell
kubectl get deployment devops-jenkins  -n   kubesphere-devops-system -o yaml   > jenkins.yaml
```

