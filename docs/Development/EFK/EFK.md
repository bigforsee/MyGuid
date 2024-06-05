# EFK



## ELK 中各个服务的作用

- Elasticsearch:用于存储收集到的日志信息；
- Logstash:用于收集日志，应用整合了 Logstash 以后会把日志发送给 Logstash,Logstash 再把日志转发给 Elasticsearch；
- Kibana:通过 Web 端的可视化界面来查看日志。



## 1 、elasticsearch

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch-logging
  namespace: sn-dev-middleware
  labels:
    k8s-app: elasticsearch-logging
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "Elasticsearch"
spec:
  ports:
  - port: 9200
    protocol: TCP
    targetPort: db
  selector:
    k8s-app: elasticsearch-logging
---
# RBAC authn and authz
apiVersion: v1
kind: ServiceAccount
metadata:
  name: elasticsearch-logging
  namespace: sn-dev-middleware
  labels:
    k8s-app: elasticsearch-logging
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: elasticsearch-logging
  labels:
    k8s-app: elasticsearch-logging
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
rules:
- apiGroups:
  - ""
  resources:
  - "services"
  - "namespaces"
  - "endpoints"
  verbs:
  - "get"
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: sn-dev-middleware
  name: elasticsearch-logging
  labels:
    k8s-app: elasticsearch-logging
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
subjects:
- kind: ServiceAccount
  name: elasticsearch-logging
  namespace: sn-dev-middleware
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: elasticsearch-logging
  apiGroup: ""
---
# Elasticsearch deployment itself
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: elasticsearch-logging
  namespace: sn-dev-middleware
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
    k8s-app: elasticsearch-logging
    kubernetes.io/cluster-service: 'true'
    srv: srv-elasticsearch
  annotations:
    kubesphere.io/creator: admin
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: elasticsearch-logging
  template:
    metadata:
      creationTimestamp: null
      labels:
        k8s-app: elasticsearch-logging
        kubernetes.io/cluster-service: 'true'
      annotations:
        kubesphere.io/restartedAt: '2023-12-25T08:05:56.293Z'
    spec:
      volumes:
        - name: elasticsearch-logging
          hostPath:
            path: /data/es/
            type: ''
      initContainers:
        - name: elasticsearch-logging-init
          image: 'alpine:3.6'
          command:
            - /sbin/sysctl
            - '-w'
            - vm.max_map_count=262144
          resources: {}
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
          securityContext:
            privileged: true
        - name: increase-fd-ulimit
          image: busybox
          command:
            - sh
            - '-c'
            - ulimit -n 65536
          resources: {}
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
          securityContext:
            privileged: true
        - name: elasticsearch-volume-init
          image: 'alpine:3.6'
          command:
            - chmod
            - '-R'
            - '777'
            - /usr/share/elasticsearch/data/
          resources: {}
          volumeMounts:
            - name: elasticsearch-logging
              mountPath: /usr/share/elasticsearch/data/
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
      containers:
        - name: elasticsearch-logging
          image: 'docker.io/library/elasticsearch:7.9.3'
          ports:
            - name: db
              containerPort: 9200
              protocol: TCP
            - name: transport
              containerPort: 9300
              protocol: TCP
          env:
            - name: NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
            - name: discovery.type
              value: single-node
            - name: ES_JAVA_OPTS
              value: '-Xms512m -Xmx2g'
          resources:
            limits:
              cpu: '1'
              memory: 2Gi
            requests:
              cpu: 100m
              memory: 500Mi
          volumeMounts:
            - name: elasticsearch-logging
              mountPath: /usr/share/elasticsearch/data/
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirst
      nodeSelector:
        kubernetes.io/hostname: k8s-node171
      serviceAccountName: elasticsearch-logging
      serviceAccount: elasticsearch-logging
      securityContext: {}
      schedulerName: default-scheduler
      tolerations:
        - operator: Exists
          effect: NoSchedule
  serviceName: elasticsearch-logging
  podManagementPolicy: OrderedReady
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0
  revisionHistoryLimit: 10

```









## 2、 kibana

cat kibana.yaml

```text
---
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: sn-dev-middleware
  labels:
    k8s-app: kibana
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "Kibana"
    srv: srv-kibana
spec:
  type: NodePort #采用nodeport方式进行暴露，端口默认为25601
  ports:
  - port: 5601
    nodePort: 32601
    protocol: TCP
    targetPort: ui
  selector:
    k8s-app: kibana
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
  namespace: sn-dev-middleware
  labels:
    k8s-app: kibana
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    srv: srv-kibana
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: kibana
  template:
    metadata:
      labels:
        k8s-app: kibana
      annotations:
        seccomp.security.alpha.kubernetes.io/pod: 'docker/default'
    spec:
      containers:
      - name: kibana
        image: docker.io/kubeimages/kibana:7.9.3 #该镜像支持arm64和amd64两种架构
        resources:
          # need more cpu upon initialization, therefore burstable class
          limits:
            cpu: 1000m
          requests:
            cpu: 100m
        env:
          - name: ELASTICSEARCH_HOSTS
            value: http://elasticsearch-logging:9200
        ports:
        - containerPort: 5601
          name: ui
          protocol: TCP
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kibana
  namespace: sn-dev-middleware
spec:
  rules:
  - host: kibana.ctnrs.com
    http:
      paths:
      - path: /
        backend:
          serviceName: kibana
          servicePort: 5601
```



3.logstash

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: logstash
  namespace: sn-dev-middleware
spec:
  ports:
  - port: 5044
    targetPort: beats
  selector:
    type: logstash
  clusterIP: None
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logstash
  namespace: sn-dev-middleware
spec:
  selector:
    matchLabels:
      type: logstash
  template:
    metadata:
      labels:
        type: logstash
        srv: srv-logstash
    spec:
      containers:
      - image: docker.io/kubeimages/logstash:7.9.3 #该镜像支持arm64和amd64两种架构
        name: logstash
        ports:
        - containerPort: 5044
          name: beats
        command:
        - logstash
        - '-f'
        - '/etc/logstash_c/logstash.conf'
        env:
        - name: "XPACK_MONITORING_ELASTICSEARCH_HOSTS"
          value: "http://elasticsearch-logging:9200"
        volumeMounts:
        - name: config-volume
          mountPath: /etc/logstash_c/
        - name: config-yml-volume
          mountPath: /usr/share/logstash/config/
        - name: timezone
          mountPath: /etc/localtime
        resources: #logstash一定要加上资源限制，避免对其他业务造成资源抢占影响
          limits:
            cpu: 1000m
            memory: 2048Mi
          requests:
            cpu: 512m
            memory: 512Mi
      volumes:
      - name: config-volume
        configMap:
          name: logstash-conf
          items:
          - key: logstash.conf
            path: logstash.conf
      - name: timezone
        hostPath:
          path: /etc/localtime
      - name: config-yml-volume
        configMap:
          name: logstash-yml
          items:
          - key: logstash.yml
            path: logstash.yml

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: logstash-conf
  namespace: sn-dev-middleware
  labels:
    type: logstash
data:
  logstash.conf: |-
    input {
      beats {
      port => 5044
      }
     }
     filter{ 
     # 处理ingress日志
     if [kubernetes][container][name] == "nginx-ingress-controller" {
            json {
       source => "message"
       target => "ingress_log"
     }
     if [ingress_log][requesttime] {
         mutate {
        convert => ["[ingress_log][requesttime]", "float"]
    }
    }
     if [ingress_log][upstremtime] {
         mutate {
        convert => ["[ingress_log][upstremtime]", "float"]
    }
    }
     if [ingress_log][status] {
         mutate {
        convert => ["[ingress_log][status]", "float"]
    }
    }
     if  [ingress_log][httphost] and [ingress_log][uri] {
         mutate {
        add_field => {"[ingress_log][entry]" => "%{[ingress_log][httphost]}%{[ingress_log][uri]}"}
    }
         mutate{
         split => ["[ingress_log][entry]","/"]
       }
         if [ingress_log][entry][1] {
         mutate{
         add_field => {"[ingress_log][entrypoint]" => "%{[ingress_log][entry][0]}/%{[ingress_log][entry][1]}"}
         remove_field => "[ingress_log][entry]"
         }
         }
         else{
          mutate{
          add_field => {"[ingress_log][entrypoint]" => "%{[ingress_log][entry][0]}/"}
          remove_field => "[ingress_log][entry]"
         }
         }
    }
    }
     # 处理以srv进行开头的业务服务日志
     if [kubernetes][container][name] =~ /^srv*/ {
       json {
       source => "message"
       target => "tmp"
     }
    if [kubernetes][namespace] == "kube-system" {
       drop{}
     }
       if [tmp][level] {
       mutate{
       add_field => {"[applog][level]" => "%{[tmp][level]}"}
     }
       if [applog][level] == "debug"{
       drop{}
     }
     }
       if [tmp][msg]{
      mutate{
       add_field => {"[applog][msg]" => "%{[tmp][msg]}"}
     }
     }
       if [tmp][func]{
      mutate{
       add_field => {"[applog][func]" => "%{[tmp][func]}"}
     }
     }
      if [tmp][cost]{
        if "ms" in [tmp][cost]{
        mutate{
          split => ["[tmp][cost]","m"]
          add_field => {"[applog][cost]" => "%{[tmp][cost][0]}"}
          convert => ["[applog][cost]", "float"]
        }
        }
        else{
        mutate{
        add_field => {"[applog][cost]" => "%{[tmp][cost]}"}
      }
      }
     }
      if [tmp][method]{
      mutate{
       add_field => {"[applog][method]" => "%{[tmp][method]}"}
     }
     }
      if [tmp][request_url]{
      mutate{
       add_field => {"[applog][request_url]" => "%{[tmp][request_url]}"}
     }
     }
       if [tmp][meta._id]{
       mutate{
       add_field => {"[applog][traceId]" => "%{[tmp][meta._id]}"}
     }
     }
       if [tmp][project] {
       mutate{
       add_field => {"[applog][project]" => "%{[tmp][project]}"}
     }
     }
       if [tmp][time] {
       mutate{
       add_field => {"[applog][time]" => "%{[tmp][time]}"}
     }
     }
       if [tmp][status] {
       mutate{
       add_field => {"[applog][status]" => "%{[tmp][status]}"}
       convert => ["[applog][status]", "float"]
     }
     }
     }
    mutate{
      rename => ["kubernetes", "k8s"]
      remove_field => "beat"
      remove_field => "tmp"
      remove_field => "[k8s][labels][app]"
    }
    }
    output{
      elasticsearch {
        hosts => ["http://elasticsearch-logging:9200"]
        codec => json
        index => "logstash-%{+YYYY.MM.dd}" #索引名称以logstash+日志进行每日新建
        }
      }
---

apiVersion: v1
kind: ConfigMap
metadata:
  name: logstash-yml
  namespace: sn-dev-middleware
  labels:
    type: logstash
data:
  logstash.yml: |-
    http.host: "0.0.0.0"
    xpack.monitoring.elasticsearch.hosts: http://elasticsearch-logging:9200
```



## 基于docker-compose部署elk

> ### 创建对应挂载目录

```shell
mkdir -p /mydata/logstash

mkdir -p /mydata/elasticsearch/data

mkdir -p /mydata/elasticsearch/plugins


chmod 777 /mydata/elasticsearch/data  # 给777权限，不然启动elasticsearch 可能会有权限问题


```

> ### 创建`docker-compose`文件 

> ```shell
> vi docker-compose.yml
> ```

```yaml
version: '3'
services:
  elasticsearch:
    image: elasticsearch:6.4.0
    container_name: elasticsearch
    environment:
      - "cluster.name=elasticsearch" #设置集群名称为elasticsearch
      - "discovery.type=single-node" #以单一节点模式启动
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m" #设置使用jvm内存大小
    volumes:
      - /mydata/elasticsearch/plugins:/usr/share/elasticsearch/plugins #插件文件挂载
      - /mydata/elasticsearch/data:/usr/share/elasticsearch/data #数据文件挂载
    ports:
      - 9200:9200
  kibana:
    image: kibana:6.4.0
    container_name: kibana
    links:
      - elasticsearch:es #可以用es这个域名访问elasticsearch服务
    depends_on:
      - elasticsearch #kibana在elasticsearch启动之后再启动
    environment:
      - "elasticsearch.hosts=http://es:9200" #设置访问elasticsearch的地址
    ports:
      - 5601:5601
  logstash:
    image: logstash:6.4.0
    container_name: logstash
    volumes:
      - /mydata/logstash/upms-logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch #kibana在elasticsearch启动之后再启动
    links:
      - elasticsearch:es #可以用es这个域名访问elasticsearch服务
    ports:
      - 4560-4600:4560-4600

```



### 编写日志采集 logstash

在 `/mydata/logstash`目录创建 `upms-logstash.conf`

```yaml
cd /mydata/logstash
vi upms-logstash.conf
```



```yaml
input {
  tcp {
    mode => "server"
    host => "0.0.0.0"
    port => 4560
    codec => json_lines
  }
}
output {
  elasticsearch {
    hosts => "es:9200"
    index => "upms-logstash-%{+YYYY.MM.dd}"
  }
}
```



### logstash 安装 json_lines 格式插件

```yaml
# 进入logstash容器
docker exec -it logstash /bin/bash
# 进入bin目录
cd /bin/
# 安装插件
logstash-plugin install logstash-codec-json_lines
# 退出容器
exit
# 重启logstash服务
docker restart logstash
```



### 添加 pom 依赖

```java
<!--集成logstash-->
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>5.3</version>
</dependency>

```

### logback-spring.xml 新增 appender

```xml
 <!--输出到logstash的appender-->
<appender name="LOGSTASH" class="net.logstash.logback.appender.LogstashTcpSocketAppender">
    <!--可以访问的logstash日志收集端口-->
    <destination>192.168.0.31:4560</destination>
    <encoder charset="UTF-8" class="net.logstash.logback.encoder.LogstashEncoder"/>
</appender>
<root level="INFO">
    <appender-ref ref="LOGSTASH"/>
</root>
```

