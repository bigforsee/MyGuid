# 启用nacos注册发现中心

## 1. 加入版本约束

```pom
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>com.alibaba.cloud</groupId>
                <artifactId>spring-cloud-alibaba-dependencies</artifactId>
                <version>2.2.1.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```



## 2. 加入启动项

```pom
        <!--   服务的注册发现    -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
        </dependency>
		<!--          配置中心管理    -->
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
        </dependency>
```

## 3. 启动服务加入注解 @EnableDiscoveryClient

```java
@EnableDiscoveryClient
```



## 4.配置项

```yml
  cloud:
    nacos:
      discovery:
        server-addr: 127.0.0.1:8848  #注册发现中心IP:端口
        port: ${server.port}         #本服务端口
        ip: 127.0.0.1                #本服务IP地址
        group: sn					 #组
        namespace: b45f822a-a3dd-4977-b1c1-032146864d13    #namespace 命名空间ID
      config:						#配置中心
        server-addr: ${spring.cloud.nacos.discovery.server-addr}
        namespace: ${spring.cloud.nacos.discovery.namespace}
        group: ${spring.cloud.nacos.discovery.group}
```

## 5.配置取名字要与配置项里面的`application.name`保持一致



## 6.使用 `使用注解@RefreshScope`

`获取某个配置的值` 动态获取并并刷新配置

```java
@Value("${coupon.user.name}")//${coupon.user.name}为配置项的key
```



## 7.细节

### 1.命名空间

默认public,可以新建  开发环境 dev  测试环境test  生产换环境 prod

2.配置集

3.配置集ID

4.配置分组



## 配置

