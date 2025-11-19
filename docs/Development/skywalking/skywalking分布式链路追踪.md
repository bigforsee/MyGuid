# 分布式链路追踪Skywalking

## 1、skywalking是什么

​		它是一款优秀的APM（Application Performance Management）工具，包括了分布式追踪、性能指标分析、应用额服务依赖分析。

​		skywalking是分布式系统的应用程序 **性能监视工具** 专门为微服务云原生框架和基于容器（docker k8s、mesos）架构而设计。

官网 :  [https://skywalking.apache.org/](https://skywalking.apache.org/)      [下载地址](https://skywalking.apache.org/downloads/)     [中文文档](https://skyapm.github.io/document-cn-translation-of-skywalking/)

## 1.2链路追踪框架对比

1. **Zipkin** Zipkin中针对 HttpClient、jax-rs2、jersey/jersey2等HTTP客户端封装了拦截器。可以在较小的代码侵入条件下实现URl请求的拦截、时间统计和日志记录等操作。
2. **Pinpoint** Pinpoint 是一个完整的性能监控解决方案：有从探针、收集器、存储到 Web 界面等全套体系
3. SkyWalking
4. CAT

| 项目         | Cat                 | Zipkin        | Skywalking               |
| ------------ | ------------------- | ------------- | ------------------------ |
| 调用链可视化 | 有                  | 有            | 有                       |
| 聚合报表     | 非常丰富            | 少            | 较丰富                   |
| 服务依赖图   | 简单                | 简单          | 好                       |
| 埋点方式     | 侵入式              | 侵入式        | 非侵入式，字节码强       |
| VM监控指标   | 好                  | 无            | 有                       |
| 支持语言     | JAVA/.net           | 丰富          | java/.net/node.js/php/go |
| 存储机制     | mysql 本地文件/hdfs | 内存,es,mysql | H2,es                    |

## 1.3性能对比

​		![image-20220130101642914](images\image-20220130101642914.png)



## 1.4 Skywalking 主要功能特性

1. 多种监控手段，可以通过语言探针和service mesh 获得监控的数据
2. 支持多种语言自动探针，包裹JAVA ，.NET Core 和N Node.JS
3. 清亮搞笑，无需大数据平台和大量服务器资源；
4. 模块化，UI ，存储，集群管理都有多种机制可选；
5. 支持告警；
6. 优秀的可视化解决方案；

## 2、环境搭建部署

![image-20220130102639715](images\image-20220130102639715.png)

- skywalking agent 和业务系统绑定 在一起，负责收集各种监控数据
- Skywalking opaservice 是负责处理监控数据的，比如接受skywalking agent的监控数据，并存储在数据库种中，接受skywalking webapp的前端技术，从数据查询数据，并返回数据给前端，Skywlking oapservice通常以集群的形式存在。
- 用于存储监控数据的数据库，比如mysql 、elasticsearch等



## 2.1 下载

[下载 ](https://skywalking.apache.org/downloads/)

> 参考结合的软件选择版本

![image-20220130103117508](images\image-20220130103117508.png)



### **文件目录结构**

- **webapp** : UI前端的jar包和配置文件；
- **oap-libs** : 后台应用的 `jar` 以及他的依赖jar包，里面有一个server-starter-*.jar 启动程序
- **config** : 启动后台应用程序的配置文件，是使用的各种配置
- **bin** : 各种启动脚本，一般使用 startup.* 来启动**web页面** 和对应的 **后台应用**；
- agent:
  - skywalking-agant.jar:代理服务jar包
  - config:配置文件
  - plugins:包含多个插件，代理服务启动时回加载该目录下的所有插件
  - optinal-plugins: 可选插件当需要某种插件时拷贝到plugins目录即可

**启动命令**

```shell
#解压到/usr/local/skywalking目录
/usr/local/skywalking/bin/startup.sh
```

启动完成有2个服务

**skywalking-oap-server** :

- 收集监控数据端口：11800

- 接受前端请求接口：12800

  ```shell
  #修改配置
  config/application.yml
  ```

**webapp-server**

- UI 默认端口8080

- ` skywalking/webapp/webapp.yml` 

## idea使用

添加参数`agent.service_name` `collector.backend_service`

```java
-javaagent:C:\project\demo\skywalking\apache-skywalking-apm-es7-8.5.0.tar\apache-skywalking-apm-bin-es7\agent\skywalking-agent.jar=agent.service_name=pigx-upmsadmin
```

**tomcat使用**

- Linux Tomcat 7, Tomcat 8
  修改`tomcat/bin/catalina.sh`的第一行。

```java
CATALINA_OPTS="$CATALINA_OPTS -javaagent:/path/to/skywalking-agent/skywalking-agent.jar"; export CATALINA_OPTS
```

- Windows Tomcat 7, Tomcat 8
  修改`tomcat/bin/catalina.bat`的第一行。

  ```windows
  set "CATALINA_OPTS=-javaagent:/path/to/skywalking-agent/skywalking-agent.jar"
  ```

- JAR包 使用命令行启动应用时，添加`-javaagent`参数。比如：

```shell
java -javaagent:/path/to/skywalking-agent/skywalking-agent.jar -jar yourApp.jar
```

- Jetty
  修改 `jetty.sh`, 在启动应用程序的命令行中添加 `-javaagent` 参数. 比如:

```shell
export JAVA_OPTIONS="${JAVA_OPTIONS} -javaagent:/path/to/skywalking-agent/skywalking-agent.jar"
```



## 监控数据持久化

```shell
#将默认的h2修改为
storage:
  selector: ${SW_STORAGE:mysql}
#对应的mysql:相关配置要设置完全，比如我的 新建库swtest
  mysql:
    properties:
      jdbcUrl: ${SW_JDBC_URL:"jdbc:mysql://192.168.56.159d:3306/swtest"}
      dataSource.user: ${SW_DATA_SOURCE_USER:root}
      dataSource.password: ${SW_DATA_SOURCE_PASSWORD:root}
```

**修改完后需要为数据库提供驱动**

```shell
#在其他项目里面找到这个路径，
mysql\mysql-connector-java
#复制类似的jar到 skywalking/oap-libs/目录下
mysql-connector-java-8.0.27.jar
```







```shell
-javaagent:/Users/zhouxianhai/Downloads/skywalking-agent/skywalking-agent.jar
-Dskywalking.agent.service_name=gateway
-Dskywalking.collector.backend_service=10.30.30.167:32233

```







## 自定义链路追踪

```xml
		<dependency>
			<groupId>org.apache.skywalking</groupId>
			<artifactId>apm-toolkit-trace</artifactId>
			<version>8.5.0</version>
		</dependency>
```

> version 要于自己下载使用的版本一致

@Trace注解其只能在方法上进行注解,使用operationName属性指定Span的名字,若不指定,会使用方法名.

个人理解：方法名，用于追踪后查看的显示名

```java
    @Trace(operationName = "customTraceFunction")
    private String trace(String plaintext) {
        return new Base64().encodeToString(plaintext.getBytes(StandardCharsets.UTF_8));
    }
```

## 使用@Tags/ @Tag注解添加Span的属性

用于需要展现的数据

```java
    @Trace(operationName = "customTraceFunction")
    @Tags({@Tag(key = "plaintext", value = "arg[0]"), @Tag(key = "ciphertext", value = "returnedObj")})
    private String trace(String plaintext) {
        return new Base64().encodeToString(plaintext.getBytes(StandardCharsets.UTF_8));
    }
```



### 日志配置

安装目录下

```windows
\agent\config\agent.config
```







### 基于docker部署

#### es部署请查看ELK中的部署

Aop

```shell
docker run --name oap --network=elk_default \
--restart always -d  -e TZ=Asia/Shanghai -p 12800:12800 -p 11800:11800 --link elasticsearch:es -e SW_STORAGE=elasticsearch7 -e SW_STORAGE_ES_CLUSTER_NODES=es:9200 apache/skywalking-oap-server:8.3.0-es7
```

Sky walking-ui

```shell
docker run -d --name skywalking-ui \
--restart=always \
--network=elk_default \
-e TZ=Asia/Shanghai \
-p 8088:8080 \
--link oap:oap \
-e SW_OAP_ADDRESS=oap:12800 \
apache/skywalking-ui:8.3.0
```







### k8s部署SK-es

#### oap服务关联es

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: skywalking-oap
  namespace: sn-dev-middleware
  labels:
    app: skywalking-oap
  annotations:
    deployment.kubernetes.io/revision: '1'
    kubesphere.io/creator: admin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: skywalking-oap
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: skywalking-oap
      annotations:
        cni.projectcalico.org/ipv4pools: '["ippool-dianxin"]'
    spec:
      volumes:
        - name: host-time
          hostPath:
            path: /etc/localtime
            type: ''
      containers:
        - name: skywalking-oap
          image: 'apache/skywalking-oap-server:8.4.0-es7'
          ports:
            - name: tcp-11800
              containerPort: 11800
              protocol: TCP
            - name: tcp-1234
              containerPort: 1234
              protocol: TCP
            - name: tcp-12800
              containerPort: 12800
              protocol: TCP
          env:
            - name: SW_STORAGE
              value: elasticsearch7
            - name: SW_STORAGE_ES_CLUSTER_NODES
              value: 'elasticsearch-logging:9200'
          resources:
            limits:
              cpu: 500m
              memory: 512Mi
            requests:
              cpu: 10m
              memory: 64Mi
          volumeMounts:
            - name: host-time
              readOnly: true
              mountPath: /etc/localtime
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      dnsPolicy: ClusterFirst
      securityContext: {}
      affinity: {}
      schedulerName: default-scheduler
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 25%
      maxSurge: 25%
  revisionHistoryLimit: 10
  progressDeadlineSeconds: 600
---
apiVersion: v1
kind: Service
metadata:
  name: skywalking-oap
  namespace: sn-dev-middleware
  labels:
    service: skywalking-oap
spec:
  ports:
    - port: 12800
      name: rest
    - port: 11800
      name: grpc
    - port: 1234
      name: 1234
  selector:
    app: skywalking-oap
```



#### 部署skywalking-ui

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: skywalking-ui
  namespace: sn-dev-middleware
  labels:
    app: skywalking-ui
spec:
  replicas: 1
  selector:
    matchLabels:
      app: skywalking-ui
  template:
    metadata:
      labels:
        app: skywalking-ui
    spec:
      containers:
        - name: skywalking-ui
          image: apache/skywalking-ui:8.4.0
          ports:
            - containerPort: 8080
              name: page
          env:
            - name: SW_OAP_ADDRESS
              value: skywalking-oap:12800 ##skywalking-oap监听端口
---
apiVersion: v1
kind: Service
metadata:
  name: skywalking-ui
  namespace: sn-dev-middleware
  labels:
    service: skywalking-ui
spec:
  ports:
    - port: 8080
      name: page
      nodePort: 30200
  type: NodePort
  selector:
    app: skywalking-ui
```



### 基于docker-compose的部署

```shell
#预先执行
mkdir  -p /opt/docker_elk/elasticsearch/plugins /opt/docker_elk/elasticsearch/data /opt/docker_elk/logstash/logstash.conf /opt/docker_elk/kibana/config
```



```yaml
version: '3.7'
services:
  elasticsearch:
    image: elasticsearch:7.6.2
    container_name: elasticsearch
    privileged: true
    user: root
    environment:
      #设置集群名称为elasticsearch
      - cluster.name=elasticsearch 
      #以单一节点模式启动
      - discovery.type=single-node 
      #设置使用jvm内存大小
      - ES_JAVA_OPTS=-Xms512m -Xmx512m 
    volumes:
      - /opt/docker_elk/elasticsearch/plugins:/usr/share/elasticsearch/plugins
      - /opt/docker_elk/elasticsearch/data:/usr/share/elasticsearch/data
    ports:
      - 9200:9200
      - 9300:9300

  logstash:
    image: logstash:7.6.2
    container_name: logstash
    ports:
       - 4560:4560
    privileged: true
    environment:
      - TZ=Asia/Shanghai
    volumes:
      #挂载logstash的配置文件
      - /opt/docker_elk/logstash/logstash.conf:/usr/share/logstash/pipeline/logstash.conf 
    depends_on:
      - elasticsearch 
    links:
      #可以用es这个域名访问elasticsearch服务
      - elasticsearch:es 
    

  kibana:
    image: kibana:7.6.2
    container_name: kibana
    ports:
        - 5601:5601
    privileged: true
    links:
      #可以用es这个域名访问elasticsearch服务
      - elasticsearch:es 
    depends_on:
      - elasticsearch 
    environment:
      #设置访问elasticsearch的地址
      - elasticsearch.hosts=http://es:9200 
    volumes:
      - "/opt/docker_elk/kibana/config:/usr/share/kibana/config"
   
  oap:
    image: apache/skywalking-ui:8.3.0
    container_name: oap
    ports:
        - 12800:12800
        - 11800:11800
    privileged: true
    links:
      #可以用es这个域名访问elasticsearch服务
      - elasticsearch:es 
    depends_on:
      - elasticsearch 
    environment:
      #设置访问elasticsearch的地址
      - elasticsearch.hosts=http://es:9200 
      - TZ=Asia/Shanghai
      - SW_STORAGE_ES_CLUSTER_NODES=es:9200

  skywalking-ui:
    image: apache/skywalking-ui:8.3.0
    container_name: skywalking-ui
    ports:
        - 8088:8080
    privileged: true
    links:
      #可以用es这个域名访问elasticsearch服务
      - oap:oap 
    depends_on:
      - elasticsearch 
    environment:
      #设置访问elasticsearch的地址
      - SW_OAP_ADDRESS=oap:12800
      - TZ=Asia/Shanghai
```





常见问题解决

```shell
#ElasticSearch--解决this action would add [5] total shards, but this cluster currently has [1000]/[1000]
curl --location --request PUT 'http://127.0.0.1:9200/_cluster/settings' \
--header 'Content-Type: application/json' \
--data '{"persistent":{"cluster":{"max_shards_per_node":10000}}}'
```

