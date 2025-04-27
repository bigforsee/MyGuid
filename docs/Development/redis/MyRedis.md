# Redis部署

## 单节点部署

**安装一个 redis**

```shell
docker pull redis

mkdir -p /mydata/redis/conf
touch /mydata/redis/conf/redis.conf
echo "cluster-enabled yes
cluster-node-timeout 5000
cluster-require-full-coverage no
cluster-migration-barrier 1
appendonly yes
requirepass 123456" >> /mydata/redis/conf/redis.conf

docker run -p 6379:6379 --name redis --restart=always \
-v /mydata/redis/data:/data \
-v /mydata/redis/conf/redis.conf:/etc/redis/redis.conf \
-d redis redis-server /etc/redis/redis.conf 

```

设置自动启动

```shell
sudo docker update redis --restart=always
```



## Redis分布式集群搭建

### Redis有下面四种部署方式

模式	优点	缺点
单机版	架构简单，部署方便	机器故障、容量瓶颈、QPS瓶颈
主从复制	高可靠性，读写分离	故障恢复复杂，主库的写跟存受单机限制
Sentinel 哨兵	集群部署简单，HA	原理繁琐，slave存在资源浪费，不能解决读写分离问题
Redis Cluster	数据动态存储solt，可扩展，高可用	客户端动态感知后端变更，批量操作支持查

| 模式          | 优点                             | 缺点                                             |
| ------------- | -------------------------------- | ------------------------------------------------ |
| 单机版        | 架构简单，部署方便               | 机器故障、容量瓶颈、QPS瓶颈                      |
| 主从复制      | 高可靠性读写分离                 | 故障恢复复杂，主库的写跟存受单机限制             |
| Sentinel 哨兵 | 集群部署简单,HA                  | 原理繁琐,slave存在资源浪费，不能解决读写分离问题 |
| Redis Cluster | 数据动态存储solt，可扩展，高可用 | 客户端动态感知后端变更，批量操作支持查           |



## 单节点



## redis主从复制

该模式下 具有高可用性且读写分离， 会采用 `增量同步` 跟 `全量同步` 两种机制。

Redis全量复制一般发生在**Slave初始化阶段**，这时Slave需要将Master上的**所有数据**都复制一份



>1、slave连接master，发送psync命令。
>
>2、master接收到psync命名后，开始执行bgsave命令生成RDB文件并使用缓冲区记录此后执行的所有写命令。
>
>3、master发送快照文件到slave，并在发送期间继续记录被执行的写命令。4、slave收到快照文件后丢弃所有旧数据，载入收到的快照。
>
>5、master快照发送完毕后开始向slave发送缓冲区中的写命令。
>
>6、slave完成对快照的载入，开始接收命令请求，并执行来自master缓冲区的写命令。







## 分布式集群搭建



RedisCluster是Redis的分布式解决方案，在3.0版本后推出的方案，有效地解决了Redis分布式的需求。说白了就是把数据分布在不同的节点上，采用去中心化的思想

![image.png](C:\Users\周先海\OneDrive\文档\学习文档\redis\images\11889b786104dc3449d297b83bb66087.png)

分区规则如下

![img](C:\Users\周先海\OneDrive\文档\学习文档\redis\images\15fbcb833591aaffef31aa10290a11f8.png)



有下面这几个分区规则

1. `节点取余`：hash(key) % N
2. `一致性哈希`：一致性哈希环
3. `虚拟槽哈希`：CRC16[key] & 16383



**总结**

1. RedisCluster采用了虚拟槽分区方式
2. 采用去中心化的思想，它使用虚拟槽solt分区覆盖到所有节点上，取数据一样的流程，节点之间使用轻量协议通信Gossip来减少带宽占用所以性能很高
3. 自动实现负载均衡与高可用，自动实现failover并且支持动态扩展，官方已经玩到可以1000个节点 实现的复杂度低。
4. 每个Master也需要配置主从，并且内部也是采用哨兵模式，如果有半数节点发现某个异常节点会共同决定更改异常节点的状态。
5. 如果集群中的master没有slave节点，则master挂掉后整个集群就会进入fail状态，因为集群的slot映射不完整。如果集群超过半数以上的master挂掉，集群都会进入fail状态。
6. 官方推荐 集群部署至少要3台以上的master节点。





> 说明：
>
> 1.伪集群，一台服务器6个redis服务、通过区分(7001-7006)
>
> 2.真集群:6个节点或者3个节点



查看默认安装目录：/usr/local/bin

| 命令             | 描述                                                   |
| ---------------- | ------------------------------------------------------ |
| redis-benchmark  | 性能测试工具，可以在自己本子运行，看看自己本子性能如何 |
| redis-check-aof  | 修复有问题的AOF文件，rdb和aof后面讲                    |
| redis-check-dump | 修复有问题的dump.rdb文件                               |
| redis-sentinel   | Redis集群使用                                          |
| redis-server     | Redis服务器启动命令                                    |
| redis-cli        | 客户端，操作入口                                       |



> redis cluster最低是三主三从的配置



**创建集群**

> 资源清单

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: redis-conf
  namespace: default
data:
  redis.conf: |
    bind 0.0.0.0
    protected-mode yes
    port 6360
    tcp-backlog 511
    timeout 0
    tcp-keepalive 300
    daemonize no
    supervised no
    pidfile /data/redis.pid
    loglevel notice
    logfile /data/redis_log
    databases 16
    always-show-logo yes
    save 900 1
    save 300 10
    save 60 10000
    stop-writes-on-bgsave-error yes
    rdbcompression yes
    rdbchecksum yes
    dbfilename dump.rdb
    dir /data
    masterauth iloveyou
    replica-serve-stale-data yes
    replica-read-only yes
    repl-diskless-sync no
    repl-diskless-sync-delay 5
    repl-disable-tcp-nodelay no
    replica-priority 100
    requirepass iloveyou
    lazyfree-lazy-eviction no
    lazyfree-lazy-expire no
    lazyfree-lazy-server-del no
    replica-lazy-flush no
    appendonly no
    appendfilename "appendonly.aof"
    appendfsync everysec
    no-appendfsync-on-rewrite no
    auto-aof-rewrite-percentage 100
    auto-aof-rewrite-min-size 64mb
    aof-load-truncated yes
    aof-use-rdb-preamble yes
    lua-time-limit 5000
    cluster-enabled yes
    cluster-config-file nodes.conf
    cluster-node-timeout 15000
    slowlog-log-slower-than 10000
    slowlog-max-len 128
    latency-monitor-threshold 0
    notify-keyspace-events ""
    hash-max-ziplist-entries 512
    hash-max-ziplist-value 64
    list-max-ziplist-size -2
    list-compress-depth 0
    set-max-intset-entries 512
    zset-max-ziplist-entries 128
    zset-max-ziplist-value 64
    hll-sparse-max-bytes 3000
    stream-node-max-bytes 4096
    stream-node-max-entries 100
    activerehashing yes
    client-output-buffer-limit normal 0 0 0
    client-output-buffer-limit replica 256mb 64mb 60
    client-output-buffer-limit pubsub 32mb 8mb 60
    hz 10
    dynamic-hz yes
    aof-rewrite-incremental-fsync yes
    rdb-save-incremental-fsync yes
```

```yaml
---
kind: Service
apiVersion: v1
metadata:
  name: redis-svc
  namespace: default
  labels:
    app: redis-svc
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: >
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"app":"redis-svc"},"name":"redis-svc","namespace":"default"},"spec":{"clusterIP":"None","ports":[{"port":6360,"protocol":"TCP","targetPort":6360}],"selector":{"app":"redis"},"type":"ClusterIP"}}
spec:
  ports:
    - protocol: TCP
      port: 6360
      targetPort: 6360
  selector:
    app: redis
  clusterIP: None
  clusterIPs:
    - None
  type: ClusterIP
  sessionAffinity: None
  ipFamilies:
    - IPv4
  ipFamilyPolicy: SingleStack
  internalTrafficPolicy: Cluster
---
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: redis-sts
  namespace: default
  labels:
    app: redis-sts
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: >
      {"apiVersion":"apps/v1","kind":"StatefulSet","metadata":{"annotations":{},"labels":{"app":"redis-sts"},"name":"redis-sts","namespace":"default"},"spec":{"replicas":6,"selector":{"matchLabels":{"app":"redis-sts"}},"serviceName":"redis-svc","template":{"metadata":{"labels":{"app":"redis-sts"}},"spec":{"containers":[{"args":["/etc/redis/redis.conf","--cluster-announce-ip","$(POD_IP)"],"command":["redis-server"],"env":[{"name":"POD_IP","valueFrom":{"fieldRef":{"fieldPath":"status.podIP"}}}],"image":"redis:latest","imagePullPolicy":"IfNotPresent","name":"redis","ports":[{"containerPort":6360,"name":"redis-6360"}],"volumeMounts":[{"mountPath":"/etc/redis","name":"redis-conf"},{"mountPath":"/data","name":"redis-data"}]}],"restartPolicy":"Always","volumes":[{"configMap":{"items":[{"key":"redis.conf","path":"redis.conf"}],"name":"redis-conf"},"name":"redis-conf"}]}},"volumeClaimTemplates":[{"metadata":{"name":"redis-data"},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"100M"}},"storageClassName":"managed-nfs-storage"}}]}}
spec:
  replicas: 6
  selector:
    matchLabels:
      app: redis-sts
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: redis-sts
      annotations:
        kubesphere.io/restartedAt: '2022-12-09T02:42:35.996Z'
    spec:
      volumes:
        - name: redis-conf
          configMap:
            name: redis-conf
            items:
              - key: redis.conf
                path: redis.conf
            defaultMode: 420
      containers:
        - name: redis
          image: 'redis:latest'
          command:
            - redis-server
          args:
            - /etc/redis/redis.conf
            - '--cluster-announce-ip'
            - $(POD_IP)
          ports:
            - name: redis-6360
              containerPort: 6360
              protocol: TCP
          env:
            - name: POD_IP
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: status.podIP
          resources: {}
          volumeMounts:
            - name: redis-conf
              mountPath: /etc/redis
            - name: redis-data
              mountPath: /data
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirst
      securityContext: {}
      schedulerName: default-scheduler
  volumeClaimTemplates:
    - kind: PersistentVolumeClaim
      apiVersion: v1
      metadata:
        name: redis-data
        creationTimestamp: null
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 100M
        storageClassName: managed-nfs-storage
        volumeMode: Filesystem
      status:
        phase: Pending
  serviceName: redis-svc
  podManagementPolicy: OrderedReady
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0
  revisionHistoryLimit: 10
```



先启动6个redis

```shell
#redis-cli --cluster create --cluster-replicas 1 后面是6个IP:6379 默认前三一半数量为主
#Can I set the above configurationg? 是否只有创建 输入 yes
```



```shell
kubectl exec -it redis-sts-0 -- redis-cli -a iloveyou --cluster create --cluster-replicas 1 $(kubectl get pods -l app=redis-sts -o jsonpath='{range.items[*]}{.status.podIP}:6360 {end}')
```

验证集群

```shell
kubectl exec -it redis-sts-0 -- redis-cli -a iloveyou --cluster check  $(kubectl get pods -l app=redis-sts -o jsonpath='{range.items[0]}{.status.podIP}:6360 {end}')
```



> 这个方法集群坏掉就起不来了，可能需要清空数据重新初始化



## Helm部署

- helm pull:    下载chart到本地目录查看
- helm install:   上传chart到Kubernetes
- helm list:     列出已发布的chart

```shell
helm repo add my-repo https://charts.bitnami.com/bitnami
#直接安装 指定 --namespace sn-dev-middleware  以及名称前缀
helm install --namespace sn-dev-middleware --set persistence.storageClass=managed-nfs-storage --set password=Snredis@hb30.com sn-prod my-repo/redis-cluster
```

可以下载下来

```shell
helm pull my-repo/redis-cluster --untar
```

部署示例

```shell
helm install -f values.yaml sn-dev --namespace sn-dev-middleware ./
```



> 创建完成会显示

```shell
NAME: sn-prod
LAST DEPLOYED: Fri Dec  9 15:34:50 2022
NAMESPACE: sn-dev-middleware
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: redis-cluster
CHART VERSION: 8.3.1
APP VERSION: 7.0.5** Please be patient while the chart is being deployed **


To get your password run:
    export REDIS_PASSWORD=$(kubectl get secret --namespace "sn-dev-middleware" sn-prod-redis-cluster -o jsonpath="{.data.redis-password}" | base64 -d)

You have deployed a Redis&reg; Cluster accessible only from within you Kubernetes Cluster.INFO: The Job to create the cluster will be created.To connect to your Redis&reg; cluster:

1. Run a Redis&reg; pod that you can use as a client:
kubectl run --namespace sn-dev-middleware sn-prod-redis-cluster-client --rm --tty -i --restart='Never' \
 --env REDIS_PASSWORD=$REDIS_PASSWORD \
--image docker.io/bitnami/redis-cluster:7.0.5-debian-11-r19 -- bash

2. Connect using the Redis&reg; CLI:

redis-cli -c -h sn-prod-redis-cluster -a $REDIS_PASSWORD

```



### 卸载

```shell
#kubectl get ns
helm uninstall my-release --namespace sn-dev-middleware
#安装时的namespace
```



## 总结:

​		helm 部署 `redis` 非常便利快捷, helm 是为 `kubernetes`  快捷部署而生的,要多多学习 `helm` 部署
