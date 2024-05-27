config解释

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

