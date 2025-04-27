# SEATA

## config解释

```yaml
# seata配置
seata:
  enabled: true
  # Seata 应用编号，默认为 ${spring.application.name}
  application-id: ${spring.application.name}
  # Seata 事务组编号，用于 TC 集群名
  tx-service-group: ${spring.application.name}-group
  # 关闭自动代理
  enable-auto-data-source-proxy: false
  # 服务配置项
  service:
    # 虚拟组和分组的映射
    vgroup-mapping:
      paas-protocol-group: default
  config:
    type: nacos
    nacos:
      server-addr: 127.0.0.1:8848
      namespace:
      #可选
      username: nacos
      #可选
      password: nacos
      # 这是默认值
      # data-id: seata.properties
      # 这是默认值
      group: SEATA_GROUP

  registry:
    type: nacos
    nacos:
      server-addr: 127.0.0.1:8848
      namespace:
      #可选
      username: nacos
      #可选
      password: nacos
      #可选
      application: seata-server
      #默认值和 config 的 SEATA_GROUP 不一样 
      group: SEATA_GROUP
      # 可选  默认
      cluster: default 
```



## WMS配置

### 创建 `ConfigMap` 配置文件 用于挂载入容器

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: seata-server
  namespace: sn-wms
  annotations:
    kubesphere.io/creator: admin
data:
  application.yml: >
    #  Copyright 1999-2019 Seata.io Group.

    #

    #  Licensed under the Apache License, Version 2.0 (the "License");

    #  you may not use this file except in compliance with the License.

    #  You may obtain a copy of the License at

    #

    #  http://www.apache.org/licenses/LICENSE-2.0

    #

    #  Unless required by applicable law or agreed to in writing, software

    #  distributed under the License is distributed on an "AS IS" BASIS,

    #  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

    #  See the License for the specific language governing permissions and

    #  limitations under the License.


    server:
      port: 7091

    spring:
      application:
        name: seata-server

    logging:
      config: classpath:logback-spring.xml
      file:
        path: ${user.home}/logs/seata
      extend:
        logstash-appender:
          destination: 127.0.0.1:4560
        kafka-appender:
          bootstrap-servers: 127.0.0.1:9092
          topic: logback_to_logstash

    console:
      user:
        username: seata
        password: seata

    seata:
      config:
        # support: nacos, consul, apollo, zk, etcd3
        type: nacos
        nacos:
          ip: 10.30.30.167
          port: 31695
          server-addr: 10.30.30.167:30788
          namespace: WMS
          group: sn-wms
          username: nacos
          password: Hb30!@Nacos30
          data-id: seataServer.properties
      registry:
        # support: nacos, eureka, redis, zk, consul, etcd3, sofa
        type: nacos
        nacos:
          ip: 10.30.30.167
          port: 31695
          application: seata-server
          server-addr: ${seata.config.nacos.server-addr}
          namespace: ${seata.config.nacos.namespace}
          group: ${seata.config.nacos.group}
          username: ${seata.config.nacos.username}
          password: ${seata.config.nacos.password}
          cluster: default
    #  server:

    #    service-port: 8091 #If not configured, the default is '${server.port} +
    1000'
      security:
        secretKey: SeataSecretKey0c382ef121d778043159209298fd40bf3850a017
        tokenValidityInMilliseconds: 1800000
        ignore:
          urls: /,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-fe/public/**,/api/v1/auth/login

```



### 在nacos内创建配置文件 `seataServer.properties` 启动服务时加入

```properties
#For details about configuration items, see https://seata.io/zh-cn/docs/user/configurations.html
#Transport configuration, for client and server
transport.type=TCP
transport.server=NIO
transport.heartbeat=true
transport.enableTmClientBatchSendRequest=false
transport.enableRmClientBatchSendRequest=true
transport.enableTcServerBatchSendResponse=false
transport.rpcRmRequestTimeout=30000
transport.rpcTmRequestTimeout=30000
transport.rpcTcRequestTimeout=30000
transport.threadFactory.bossThreadPrefix=NettyBoss
transport.threadFactory.workerThreadPrefix=NettyServerNIOWorker
transport.threadFactory.serverExecutorThreadPrefix=NettyServerBizHandler
transport.threadFactory.shareBossWorker=false
transport.threadFactory.clientSelectorThreadPrefix=NettyClientSelector
transport.threadFactory.clientSelectorThreadSize=1
transport.threadFactory.clientWorkerThreadPrefix=NettyClientWorkerThread
transport.threadFactory.bossThreadSize=1
transport.threadFactory.workerThreadSize=default
transport.shutdown.wait=3
transport.serialization=seata
transport.compressor=none

#Transaction routing rules configuration, only for the client
service.vgroupMapping.default_tx_group=default
service.enableDegrade=false
service.disableGlobalTransaction=false

#Transaction rule configuration, only for the client
client.rm.asyncCommitBufferLimit=10000
client.rm.lock.retryInterval=10
client.rm.lock.retryTimes=30
client.rm.lock.retryPolicyBranchRollbackOnConflict=true
client.rm.reportRetryCount=5
client.rm.tableMetaCheckEnable=true
client.rm.tableMetaCheckerInterval=60000
client.rm.sqlParserType=druid
client.rm.reportSuccessEnable=false
client.rm.sagaBranchRegisterEnable=false
client.rm.sagaJsonParser=fastjson
client.rm.tccActionInterceptorOrder=-2147482648
client.tm.commitRetryCount=5
client.tm.rollbackRetryCount=5
client.tm.defaultGlobalTransactionTimeout=60000
client.tm.degradeCheck=false
client.tm.degradeCheckAllowTimes=10
client.tm.degradeCheckPeriod=2000
client.tm.interceptorOrder=-2147482648
client.undo.dataValidation=true
client.undo.logSerialization=jackson
client.undo.onlyCareUpdateColumns=true
server.undo.logSaveDays=7
server.undo.logDeletePeriod=86400000
client.undo.logTable=undo_log
client.undo.compress.enable=true
client.undo.compress.type=zip
client.undo.compress.threshold=64k
#For TCC transaction mode
tcc.fence.logTableName=tcc_fence_log
tcc.fence.cleanPeriod=1h

#Log rule configuration, for client and server
log.exceptionRate=100

#Transaction storage configuration, only for the server. The file, db, and redis configuration values are optional.
store.mode=db
store.lock.mode=db
store.session.mode=db

#These configurations are required if the `store mode` is `db`. If `store.mode,store.lock.mode,store.session.mode` are not equal to `db`, you can remove the configuration block.
store.db.datasource=druid
store.db.dbType=mysql
store.db.driverClassName=com.mysql.cj.jdbc.Driver
store.db.url=jdbc:mysql://10.30.30.152:3306/seata?useSSL=false&useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull&tinyInt1isBit=false&allowMultiQueries=true&serverTimezone=GMT%2B8&nullCatalogMeansCurrent=true&allowPublicKeyRetrieval=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false
store.db.user=root
store.db.password=PassW0RD@2023
store.db.minConn=5
store.db.maxConn=30
store.db.globalTable=global_table
store.db.branchTable=branch_table
store.db.distributedLockTable=distributed_lock
store.db.queryLimit=100
store.db.lockTable=lock_table
store.db.maxWait=5000

#Transaction rule configuration, only for the server
server.recovery.committingRetryPeriod=1000
server.recovery.asynCommittingRetryPeriod=1000
server.recovery.rollbackingRetryPeriod=1000
server.recovery.timeoutRetryPeriod=1000
server.maxCommitRetryTimeout=-1
server.maxRollbackRetryTimeout=-1
server.rollbackRetryTimeoutUnlockEnable=false
server.distributedLockExpireTime=10000
server.xaerNotaRetryTimeout=60000
server.session.branchAsyncQueueSize=5000
server.session.enableBranchAsyncRemove=false
server.enableParallelRequestHandle=false

#Metrics configuration, only for the server
metrics.enabled=false
metrics.registryType=compact
metrics.exporterList=prometheus
metrics.exporterPrometheusPort=9898
```



### 创建 `service.vgroupMapping.default_tx_group` 配置文件

> Text 类型

```text
default
```





## Docker下部署seata

```shell
mkdir -p /mydata/seata/conf

echo '
server:
  port: 7091

spring:
  application:
    name: seata-server

logging:
  config: classpath:logback-spring.xml
  file:
    path: ${user.home}/logs/seata
  extend:
    logstash-appender:
      destination: 127.0.0.1:4560
    kafka-appender:
      bootstrap-servers: 127.0.0.1:9092
      topic: logback_to_logstash

console:
  user:
    username: seata
    password: seata

seata:
  config:
    # support: nacos, consul, apollo, zk, etcd3
    type: nacos
    nacos:
      server-addr: 127.0.0.1:8848
      namespace: DEV
      group: wms
      username: nacos
      password: Hb30!@Nacos30
      data-id: seataServer.properties
  registry:
    # support: nacos, eureka, redis, zk, consul, etcd3, sofa
    type: nacos
    nacos:
      application: seata-server
      server-addr: ${seata.config.nacos.server-addr}
      namespace: ${seata.config.nacos.namespace}
      group: ${seata.config.nacos.group}
      username: ${seata.config.nacos.username}
      password: ${seata.config.nacos.password}
      cluster: default
  security:
    secretKey: SeataSecretKey0c382ef121d778043159209298fd40bf3850a017
    tokenValidityInMilliseconds: 1800000
    ignore:
      urls: /,/**/*.css,/**/*.js,/**/*.html,/**/*.map,/**/*.svg,/**/*.png,/**/*.ico,/console-fe/public/**,/api/v1/auth/login' >>/mydata/seata/conf/application.yml


docker run -p 8091:8091 -p 7091:7091  --name seata --restart=always \
-v /mydata/seata/conf/application.yml:/seata-server/resources/application.yml \
-e SEATA_IP=10.30.94.24 \
-d 10.30.30.171:10880/library/seataio/seata-server:1.5.2





```

