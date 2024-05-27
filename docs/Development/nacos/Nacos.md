# Nacos 

地址

[Nacos官网文档](https://github.com/nacos-group/nacos-k8s/blob/master/README-CN.md)

```
 生产http://10.30.30.167:31820/nacos 用户名nacos密码Hb30!@Nacos30
 测试http://10.30.30.167:32703/nacos 用户名nacos密码!THb30Nacos30@
```

## 历史配置项

*前提是搭建好了nfs持久化存储

### 1.创建服务nacos-headless

这个是工作负载互相发现,修改cluster.conf使用的

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: nacos-headless
  namespace: sn-prod-middleware
  labels:
    app: nacos
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
spec:
  ports:
    - port: 8848
      name: server
      targetPort: 8848
    - port: 9848
      name: client-rpc
      targetPort: 9848
    - port: 9849
      name: raft-rpc
      targetPort: 9849
    ## ����1.4.x�汾��ѡ�ٶ˿�
    - port: 7848
      name: old-raft-rpc
      targetPort: 7848
  clusterIP: None
  selector:
    app: nacos
```



### 2.创建配置项

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: nacos-cm
  namespace: sn-dev-middleware
data:
  mysql.db.name: nacos_config
  mysql.password: nacos
  mysql.port: '3306'
  mysql.user: nacos

```



### 3.创建MySql8.0数据库

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: mysql
  namespace: sn-prod-middleware
  labels:
    name: mysql
spec:
  replicas: 1
  selector:
    name: mysql
  template:
    metadata:
      labels:
        name: mysql
    spec:
      containers:
      - name: mysql
        image: nacos/nacos-mysql:8.0.16
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "root"
        - name: MYSQL_DATABASE
          value: "nacos_config"
        - name: MYSQL_USER
          value: "nacos"
        - name: MYSQL_PASSWORD
          value: "nacos"
      volumes:
      - name: mysql-data
        persistentVolumeClaim:
          claimName: nacosmysqlnfs
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: sn-prod-middleware
  labels:
    name: mysql
spec:
  ports:
  - port: 3306
    targetPort: 3306
  selector:
    name: mysql
```



### 4.创建nacos集群

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nacos-cm
  namespace: sn-prod-middleware
data:
  mysql.db.name: "nacos_config"
  mysql.port: "3306"
  mysql.user: "nacos"
  mysql.password: "nacos"
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nacos
  namespace: sn-prod-middleware
spec:
  serviceName: nacos-headless
  replicas: 3
  template:
    metadata:
      labels:
        app: nacos
      annotations:
        pod.alpha.kubernetes.io/initialized: "true"
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: "app"
                    operator: In
                    values:
                      - nacos
              topologyKey: "kubernetes.io/hostname"
      ## serviceAccountName: nfs-client-provisioner
      initContainers:
        - name: peer-finder-plugin-install
          image: nacos/nacos-peer-finder-plugin:1.1
          imagePullPolicy: Always
          volumeMounts:
            - mountPath: "/home/nacos/plugins/peer-finder"
              name: plugindir
      containers:
        - name: nacos
          imagePullPolicy: Always
          image: nacos/nacos-server:2.0.1
          resources:
            requests:
              memory: "2Gi"
              cpu: "500m"
          ports:
            - containerPort: 8848
              name: client-port
            - containerPort: 9848
              name: client-rpc
            - containerPort: 9849
              name: raft-rpc
            - containerPort: 7848
              name: old-raft-rpc
          env:
            - name: NACOS_REPLICAS
              value: "3"
            - name: SERVICE_NAME
              value: "nacos-headless"
            - name: DOMAIN_NAME
              value: "cluster.local"
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
            - name: MYSQL_SERVICE_DB_NAME
              valueFrom:
                configMapKeyRef:
                  name: nacos-cm
                  key: mysql.db.name
            - name: MYSQL_SERVICE_PORT
              valueFrom:
                configMapKeyRef:
                  name: nacos-cm
                  key: mysql.port
            - name: MYSQL_SERVICE_USER
              valueFrom:
                configMapKeyRef:
                  name: nacos-cm
                  key: mysql.user
            - name: MYSQL_SERVICE_PASSWORD
              valueFrom:
                configMapKeyRef:
                  name: nacos-cm
                  key: mysql.password
            - name: NACOS_SERVER_PORT
              value: "8848"
            - name: NACOS_APPLICATION_PORT
              value: "8848"
            - name: PREFER_HOST_MODE
              value: "hostname"
          volumeMounts:
            - name: plugindir
              mountPath: /home/nacos/plugins/peer-finder
            - name: datadir
              mountPath: /home/nacos/data
            - name: logdir
              mountPath: /home/nacos/logs
  volumeClaimTemplates:
    - metadata:
        name: plugindir
        annotations:
          volume.beta.kubernetes.io/storage-class: "nfs-client-173"
      spec:
        accessModes: [ "ReadWriteMany" ]
        resources:
          requests:
            storage: 5Gi
    - metadata:
        name: datadir
        annotations:
          volume.beta.kubernetes.io/storage-class: "nfs-client-173"
      spec:
        accessModes: [ "ReadWriteMany" ]
        resources:
          requests:
            storage: 5Gi
    - metadata:
        name: logdir
        annotations:
          volume.beta.kubernetes.io/storage-class: "nfs-client-173"
      spec:
        accessModes: [ "ReadWriteMany" ]
        resources:
          requests:
            storage: 5Gi
  selector:
    matchLabels:
      app: nacos
```









## 自己的配置

### 1.创建互相发现服务

```yaml
kind: Service
apiVersion: v1
metadata:
  name: fwoa-test-nacos-headless
  namespace: sn-fwoa-test
  labels:
    app: fwoa-test-nacos-headless
  annotations:
    kubesphere.io/creator: zxh
    service.alpha.kubernetes.io/tolerate-unready-endpoints: 'true'
spec:
  ports:
    - name: server
      protocol: TCP
      port: 8848
      targetPort: 8848
    - name: client-rpc
      protocol: TCP
      port: 9848
      targetPort: 9848
    - name: raft-rpc
      protocol: TCP
      port: 9849
      targetPort: 9849
    - name: old-raft-rpc
      protocol: TCP
      port: 7848
      targetPort: 7848
  selector:
    app: fwoa-test-nacos
  clusterIP: None
  clusterIPs:
    - None
  type: ClusterIP
  sessionAffinity: None
```



### 2.创建对外服务

```yaml
kind: Service
apiVersion: v1
metadata:
  name: nacos-server-port
  namespace: sn-fwoa-test
  labels:
    app: nacos-server-port
  annotations:
    kubesphere.io/creator: zxh
spec:
  ports:
    - name: http8848
      protocol: TCP
      port: 8848
      targetPort: 8848
      nodePort: 30481
  selector:
    app: fwoa-test-nacos
  clusterIP: 10.233.56.36
  clusterIPs:
    - 10.233.56.36
  type: NodePort
  sessionAffinity: None
  externalTrafficPolicy: Cluster
```



### 3.创建配置项

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: nacos-cm
  namespace: sn-fwoa-test
  annotations:
    kubesphere.io/alias-name: fwoa-nacos-cm
    kubesphere.io/creator: zxh
    kubesphere.io/description: OA注册中心配置
data:
  MYSQL_SERVICE_HOST: 10.30.90.85
  mysql.db.name: nacos_config
  mysql.password: 1234*Qwer@xYz
  mysql.port: '3306'
  mysql.user: root

```



### 4.创建集群工作负载

```yaml
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: fwoa-test-nacos
  namespace: sn-fwoa-test
  labels:
    app: fwoa-test-nacos
  annotations:
    kubesphere.io/creator: zxh
spec:
  replicas: 4
  selector:
    matchLabels:
      app: fwoa-test-nacos
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: fwoa-test-nacos
      annotations:
        kubesphere.io/restartedAt: '2022-06-15T08:20:16.137Z'
        logging.kubesphere.io/logsidecar-config: '{}'
        pod.alpha.kubernetes.io/initialized: 'true'
    spec:
      volumes:
        - name: host-time
          hostPath:
            path: /etc/localtime
            type: ''
      initContainers:
        - name: peer-finder-plugin-install
          image: 'nacos/nacos-peer-finder-plugin:1.1'
          resources: {}
          volumeMounts:
            - name: plugindir
              mountPath: /home/nacos/plugins/peer-finder
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: Always
      containers:
        - name: nacos
          image: 'nacos/nacos-server:v2.1.1'
          ports:
            - name: client-port
              containerPort: 8848
              protocol: TCP
            - name: client-rpc
              containerPort: 9848
              protocol: TCP
            - name: raft-rpc
              containerPort: 9849
              protocol: TCP
            - name: old-raft-rpc
              containerPort: 7848
              protocol: TCP
          env:
            - name: NACOS_REPLICAS
              value: '3'
            - name: SERVICE_NAME
              value: fwoa-test-nacos-headless
            - name: DOMAIN_NAME
              value: cluster.local
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
            - name: MYSQL_SERVICE_DB_NAME
              valueFrom:
                configMapKeyRef:
                  name: nacos-cm
                  key: mysql.db.name
            - name: MYSQL_SERVICE_PORT
              valueFrom:
                configMapKeyRef:
                  name: nacos-cm
                  key: mysql.port
            - name: MYSQL_SERVICE_USER
              valueFrom:
                configMapKeyRef:
                  name: nacos-cm
                  key: mysql.user
            - name: MYSQL_SERVICE_PASSWORD
              valueFrom:
                configMapKeyRef:
                  name: nacos-cm
                  key: mysql.password
            - name: NACOS_SERVER_PORT
              value: '8848'
            - name: NACOS_APPLICATION_PORT
              value: '8848'
            - name: PREFER_HOST_MODE
              value: hostname
            - name: MYSQL_SERVICE_HOST
              valueFrom:
                configMapKeyRef:
                  name: nacos-cm
                  key: MYSQL_SERVICE_HOST
          resources:
            requests:
              cpu: 500m
              memory: 2Gi
          volumeMounts:
            - name: plugindir
              mountPath: /home/nacos/plugins/peer-finder
            - name: datadir
              mountPath: /home/nacos/data
            - name: logdir
              mountPath: /home/nacos/logs
            - name: host-time
              mountPath: /etc/localtime
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: Always
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirst
      securityContext: {}
      affinity: {}
      schedulerName: default-scheduler
  volumeClaimTemplates:
    - kind: PersistentVolumeClaim
      apiVersion: v1
      metadata:
        name: plugindir
        namespace: sn-fwoa-test
        creationTimestamp: null
        annotations:
          volume.beta.kubernetes.io/storage-class: nfs-client-171
      spec:
        accessModes:
          - ReadWriteMany
        resources:
          requests:
            storage: 5Gi
        storageClassName: nfs-client-171
        volumeMode: Filesystem
      status:
        phase: Pending
    - kind: PersistentVolumeClaim
      apiVersion: v1
      metadata:
        name: datadir
        namespace: sn-fwoa-test
        creationTimestamp: null
        annotations:
          volume.beta.kubernetes.io/storage-class: nfs-client-171
      spec:
        accessModes:
          - ReadWriteMany
        resources:
          requests:
            storage: 5Gi
        storageClassName: nfs-client-171
        volumeMode: Filesystem
      status:
        phase: Pending
    - kind: PersistentVolumeClaim
      apiVersion: v1
      metadata:
        name: logdir
        namespace: sn-fwoa-test
        creationTimestamp: null
        annotations:
          volume.beta.kubernetes.io/storage-class: nfs-client-171
      spec:
        accessModes:
          - ReadWriteMany
        resources:
          requests:
            storage: 5Gi
        storageClassName: nfs-client-171
        volumeMode: Filesystem
      status:
        phase: Pending
  serviceName: fwoa-test-nacos-headless
  podManagementPolicy: OrderedReady
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0
  revisionHistoryLimit: 10
```





1.4版本数据库升级2.1.1需要修改数据库

```sql
ALTER TABLE config_info ADD COLUMN `encrypted_data_key` text NOT NULL COMMENT '秘钥'
ALTER TABLE config_info_beta ADD COLUMN `encrypted_data_key` text NOT NULL COMMENT '秘钥'
ALTER TABLE his_config_info ADD COLUMN `encrypted_data_key` text NOT NULL COMMENT '秘钥'
```



## 总结

### 1.首先需要一个服务是headless的内部网络服务

```yaml
#必须参数  用于容器等待获取彼此namespace 修改 cluster.ip
service.alpha.kubernetes.io/tolerate-unready-endpoints: 'true'
```



### 2. 创建配置项供服务使用

```yaml
#如果在同namespace下面的mysql可以不用配置数据库地址
```



### 3. 需要NFS存储持久化实现挂载

```shell
#没有的话需要先实现功能
```



### 4. cluter.conf 这个是集群配置必须有

```shell
vi conf/cluster.conf
fwoa-test-nacos-0.fwoa-test-nacos-headless.sn-fwoa-test.svc.cluster.local:8848
#解析: fwoa-test-nacos-0 podname  fwoa-test-nacos-headless 服务名在环境变量里配置作用就是集群互相发现的网络  sn-fwoa-test.svc namespaces.svc  cluster.local  DOMAIN_NAME的画家变量
```

### 5. 配置mysql host

```shell
jdbc:mysql://${MYSQL_SERVICE_HOST}:${MYSQL_SERVICE_PORT:3306}/${MYSQL_SERVICE_DB_NAME}?${MYSQL_SERVICE_DB_PARAM:characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false}
```

根据官方文档 {SVCNAME}_SERVICE_HOST 通过这个方式可以获取到当前 namespaces下的IP,那么同命名空间下是不用配置mysql的环境变量的,否则需要在环境变量中配置

MYSQL_SERVICE_HOST已经配置文件中也要新增对应配置

```
Environment variables
When a Pod is run on a Node, the kubelet adds a set of environment variables for each active Service. It adds {SVCNAME}_SERVICE_HOST and {SVCNAME}_SERVICE_PORT variables, where the Service name is upper-cased and dashes are converted to underscores. It also supports variables (see makeLinkVariables) that are compatible with Docker Engine's "legacy container links" feature.
```

