# PIGX 踩坑记

![image-20211228133621600](.\images\image-20211228133621600.png)

#### 模块说明

```
pig-ui  -- https://gitee.com/log4j/pig-ui

pig
├── pig-auth -- 授权服务提供[3000]
└── pig-common -- 系统公共模块
     ├── pig-common-core -- 公共工具类核心包
     ├── pig-common-datasource -- 动态数据源包
     ├── pig-common-job -- xxl-job 封装
     ├── pig-common-log -- 日志服务
     ├── pig-common-mybatis -- mybatis 扩展封装
     ├── pig-common-security -- 安全工具类
     ├── pig-common-swagger -- 接口文档
     ├── pig-common-feign -- feign 扩展封装
     └── pig-common-test -- oauth2.0 单元测试扩展封装
├── pig-register -- Nacos Server[8848]
├── pig-gateway -- Spring Cloud Gateway网关[9999]
└── pig-upms -- 通用用户权限管理模块
     └── pig-upms-api -- 通用用户权限管理系统公共api模块
     └── pig-upms-biz -- 通用用户权限管理系统业务处理模块[4000]
└── pig-visual
     └── pig-monitor -- 服务监控 [5001]
     ├── pig-codegen -- 图形化代码生成 [5002]
     ├── pig-sentinel-dashboard -- 流量高可用 [5003]
     └── pig-xxl-job-admin -- 分布式定时任务管理台 [5004]
```

#### 环境说明

| 工具  | 版本    | 备注        |
| ----- | ------- | ----------- |
| JDK   | 1.8     | 强制要求    |
| MySQL | 5.7.8 + | 强制要求    |
| Redis | 3.2 +   |             |
| node  | 14      | 不要使用 16 |
| IDE   | IDEA    | 2019+       |

点击下载: [pig4cloud 基础环境软件 ](https://www.aliyundrive.com/s/3h6N2kh5yvV)

##### 后端检查配置

```cmd
mvn -v
```

```
    C:\Users\xianhaizhou>mvn -v
Apache Maven 3.6.3 (cecedd343002696d0abb50b32b541b8a6ba2883f)
Maven home: C:\Program Files\JetBrains\IntelliJ IDEA 2021.2\plugins\maven\lib\apache-maven-3.6.3\bin\..
Java version: 1.8.0_202, vendor: Oracle Corporation, runtime: C:\Program Files\Java\jre1.8.0_202
Default locale: zh_CN, platform encoding: GBK
OS name: "windows 10", version: "10.0", arch: "amd64", family: "windows"
```

[warning] **IDE 必须安装 lombok plugin**

##### 前端前置环境

```cmd
node -v npm -v
```

[warning] **目前测试的不能使用最新版本,只能使用 14**

```
C:\Users\xianhaizhou>node -v
v14.18.1

C:\Users\xianhaizhou>npm -v
6.14.15
```

### 项目下载

```
# 下载源后端代码
git clone https://git.pig4cloud.com/pig/pigx.git
```

**账号:** 467099031
**密码:** 52981262

```bash
# 下载前端源代码
git clone https://git.pig4cloud.com/pig/pigx-ui.git

# 安装cnpm 镜像
npm install -g cnpm --registry=https://registry.npm.taobao.org

# 安装依赖
cnpm install

# 启动
npm run dev
```

### 配置数据库

```shell
docker pull mysql:5.7

mkdir -p /mydata/mysql/log /mydata/mysql/data /mydata/mysql/conf

docker run -p 3306:3306 --name mysql \
-v /mydata/mysql/log:/var/log/mysql \
-v /mydata/mysql/data:/var/lib/mysql \
-v /mydata/mysql/conf:/etc/mysql/conf.d \
-e MYSQL_ROOT_PASSWORD=root \
-e MYSQL_PASSWORD=123456 \
--restart=always \
-d mysql:5.7

```

```shell
vi /mydata/mysql/conf/my.cnf
```

```shell
[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M

# Remove leading # to revert to previous value for default_authentication_plugin,
# this will increase compatibility with older clients. For background, see:
# https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
# default-authentication-plugin=mysql_native_password
skip-host-cache
skip-name-resolve
log-error=/var/log/mysql/error.log
```

设置自动启动
```shell
sudo docker update mysql --restart=always
```

设置访问权限

```mysql
 #进入容器
 docker exec -it mysql  /bin/bash
 mysql -u root -p root
```



**安装一个 redis**

```shell
docker pull redis

mkdir -p /mydata/redis/conf
touch /mydata/redis/conf/redis.conf

docker run -p 6379:6379 --name redis --restart=always \
-v /mydata/redis/data:/data \
-v /mydata/redis/conf/redis.conf:/etc/redis/redis.conf \
-d redis redis-server /etc/redis/redis.conf \

```

设置自动启动
```shell
sudo docker update redis --restart=always
```



#### 初始化数据库

- 数据库脚本说明,数据库链接工具执行这些语句,初始化数据库

```bash
db/1scheme.sql    建库语句
db/2pigxx.sql     核心数据库
db/3pigxx_ac.sql   工作流相关数据库
db/4pigxx_job.sql  定时任务相关数据库
db/5pigxx_mp.sql   微信公众号相关数据库
db/6pigxx_config.sql  配置中心数据库
db/7pigxx_pay.sql   支付模块数据库
db/8pigxx_codegen.sql 代码生成模块数据库
```

#### 账号说明

| 系统                    | 作用               | 账号密码          |
| :---------------------- | :----------------- | :---------------- |
| pigx-ui                 | 用户登录           | admin/123456      |
| pigx-register           | nacos 注册配置中心 | nacos/nacos       |
| pigx-sentinel-dashboard | sentinel 流量保护  | sentinel/sentinel |
| pigx-monitor            | 服务监控           | pigx/pigx         |
| pigx-bi-platform        | 报表设计平台       | pigx/pigx         |

#### **配置 host**

```
C:\Windows\System32\drivers\etc
```

```cmd
10.30.94.33 pigx-mysql
10.30.94.33 pigx-nacos
10.30.94.33 pigx-redis
10.30.94.33 pigx-aoth
10.30.94.33 pigx-register
10.30.94.33 pigx-gateway
10.30.94.33 pigx-xxl
10.30.94.33 pigx-sentinel
10.30.94.33 pigx-monitor
```

#### 启动顺序

```java
#nacos
1. pigx-register/PigxNacosApplication.java
#路由初始化
2. pigx-upms-biz/PigxAdminApplication   [注意启动完毕输出路由初始化完毕再去启动其他模块]
#认证服务
4. pigx-auth/PigxAuthApplication
#网关服务
3. pigx-gateway/PigxGatewayApplication
```

#### 快速构建微服务

 **代码构建框架**

```cmd
<!-- pig-gen archetype -->
# 在空文件夹执行以下命令，或者idea 根目录输入 注意 windows 下  \ 修改成 ^
mvn archetype:generate ^
       -DgroupId=com.pig4cloud ^
       -DartifactId=pigx-zxh ^
       -Dversion=4.2.0 ^
       -Dpackage=com.pig4cloud.pigx.zxh ^
       -DarchetypeGroupId=com.pig4cloud.archetype ^
       -DarchetypeArtifactId=pigx-gen ^
       -DarchetypeVersion=4.2.0 ^
       -DarchetypeCatalog=local
```

 **页面构建表数据**

- 在基础服务上在启动 PigxCodeGenApplication 服务

- **创建表** 此处为范例

```

-- 创建测试库
create database `pigx_zxh` default character set utf8mb4 collate utf8mb4_general_ci;

USE pig_demo;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 创建测试表
DROP TABLE IF EXISTS `demo`;
CREATE TABLE `demo` ( `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
                      `username` varchar(255) DEFAULT NULL COMMENT '用户名',
                      `nicename` varchar(255) DEFAULT NULL COMMENT '昵称',
                     `create_time` datetime DEFAULT NULL COMMENT '创建时间',
                     `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
                     `update_time` datetime DEFAULT NULL COMMENT '修改时间',
                     `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
                      PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='demo 表';
2. 维护数据源 并代码生成
```

**新增数据源**

![image-20211229102534895](C:\project\pig\images\image-add-databaseSource.png)

**按表生成代码**

![image-20211229160941250](C:\project\pig\images\image-20211229160941250.png)

- **覆盖前端及后端文件及 pigxx 库执行 sql 语句**
- **给权限后需要推出重新登录才能现实**
- **设置动态路由** `需要设置断言和uri`

![image-20211229163542099](C:\project\pig\images\image-20211229163542099.png)

#### **服务限流**

- 结合动态路由新增 `RequestRateLimiter` filter 即可完成限流，具体参数参考下文
- ![img](C:\project\pig\images\20200915162841.png)

#### [POM 依赖]

```
<!--spring cloud gateway依赖-->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency>
<!--基于 reactive stream 的redis -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis-reactive</artifactId>
</dependency>
```

### SWAGGER

- 访问`http://pigx-gateway:9999/swagger-ui/index.html`打开 swagger 页面。

#### 登录加密解密

> ` PasswordDecoderFilter`

> `\src\store\modules\user.js `

-  key: 'pigxpigxpigxpigx',

> `nacos->getway详情 `

- ```
  gateway:
    encode-key: 'pigxpigxpigxpigx'
  ```

### 注解说明

#### **@Order**

```
注解@Order或者接口Ordered的作用是定义Spring IOC容器中Bean的执行顺序的优先级
```

### 跨域问题

#### nacos 配置如下配置即可

```yaml
spring:
  cloud:
    gateway:
      globalcors:
        corsConfigurations:
          "[/**]":
            allowedOriginPatterns: "*" #注意这个设置只对 spring boot 2.4+ 有效， pigx v4.0+ ,低版本 使用  allowedOrigins: "*"
            allowed-methods: "*"
            allowed-headers: "*"
            allow-credentials: true
            exposedHeaders: "Content-Disposition,Content-Type,Cache-Control"
```

### 文件系统

#### MinIo 使用

##### 单节点 Docker 部署

```shell
# 9000  端口是API 通信端口， 9001 是web管理台地址 MINIO_ROOT_USER 账号 MINIO_ROOT_PASSWORD 密码 /data 服务内部存储根目录
rm -rf  /mnt/data /mnt/config
mkdir -p /mnt/data /mnt/config
docker run -d -p 9000:9000 -p 5001:5001 --name minio1 \
  -e "MINIO_ROOT_USER=pigx" \
  -e "MINIO_ROOT_PASSWORD=pingxzxhfileoss123456" \
  -v /mnt/data:/data \
  -v /mnt/config:/config \
  minio/minio:RELEASE.2021-08-25T00-41-18Z.fips server /data --console-address ":5001"

```

`mkdir -p 先建立目录确保本地有可挂载目录`

`-v 挂载Docker 目录到本机目录 `

`--console-address ":9001" 对外暴漏端口`

_进入容器查看_

```
docker exec -it <CONTAINER ID> /bin/sh
```

群晖部署

```shell
mkdir -p /volume1/docker/minio/data /volume1/docker/minio/config
docker run -d -p 9000:9000 -p 15001:5001 --name minio1 \
  -e "MINIO_ROOT_USER=pigx" \
  -e "MINIO_ROOT_PASSWORD=pingxzxhfileoss123456" \
  -v /volume1/docker/minio/data:/data \
  -v /volume1/docker/minio/config:/config \
  minio/minio:RELEASE.2021-08-25T00-41-18Z.fips server /data --console-address ":15001"
```



##### 多磁盘挂载

```
# 9000  端口是API 通信端口， 50000 是web管理台地址 MINIO_ROOT_USER 账号 MINIO_ROOT_PASSWORD 密码 /data 服务内部存储根目录
mkdir -p /mnt/data1 /mnt/data2 /mnt/data3 /mnt/data4 /mnt/data5 /mnt/data6 /mnt/data7 /mnt/data8 /mnt/config
docker run -d -p 9000:9000 -p 50000:50000 --name minio1 \
  -e "MINIO_ROOT_USER=pigx" \
  -e "MINIO_ROOT_PASSWORD=pingxzxhfileoss123456" \
  -v /mnt/data1:/data1 \
  -v /mnt/data2:/data2 \
  -v /mnt/data3:/data3 \
  -v /mnt/data4:/data4 \
  -v /mnt/data5:/data5 \
  -v /mnt/data6:/data6 \
  -v /mnt/data7:/data7 \
  -v /mnt/data8:/data8 \
  -v /mnt/config:/config \
  minio/minio  server /data{1...8} --console-address ":50000"
```

##### 分布式 MinIO

_最少需要 4 块硬盘_

**` 注意`**

- 分布式 Minio 里所有的节点需要有同样的 access 秘钥和 secret 秘钥，这样这些节点才能建立联接。为了实现这个，你需要在执行 minio server 命令之前，先将 access 秘钥和 secret 秘钥 export 成环境变量。
- 分布式 Minio 使用的磁盘里必须是干净的，里面没有数据。
- 节点时间差不能超过 3 秒

```
#虚拟机模式下,安装了minio
export MINIO_ACCESS_KEY=<ACCESS_KEY>
export MINIO_SECRET_KEY=<SECRET_KEY>
minio server http://192.168.1.11/export1 http://192.168.1.12/export2 \
               http://192.168.1.13/export3 http://192.168.1.14/export4 \
               http://192.168.1.15/export5 http://192.168.1.16/export6 \
               http://192.168.1.17/export7 http://192.168.1.18/export8
```

`个人实现` _ 在一个环境下运行 4 个容器_

```
$ export MINIO_ROOT_USER=pigx
$ export MINIO_ROOT_PASSWORD=pingxzxhfileoss123456
$ minio server http://192.168.56.105:9101/data http://192.168.56.105:9101/data \
http://192.168.56.105:9103/data http://192.168.56.105:9104/data
rm -rf /mnt/data01 /mnt/config01  /mnt/data02 /mnt/config02 /mnt/data03 /mnt/config03 /mnt/data04 /mnt/config04
mkdir -p /mnt/data01 /mnt/config01 /mnt/data02 /mnt/config02 /mnt/data03 /mnt/config03 /mnt/data04 /mnt/config04
for i in {01..04}; do

docker run -d -p 90${i}:9000  -p 91${i}:91${i}  --name minio${i} \
  -e "MINIO_ROOT_USER=pigx" \
  -e "MINIO_ROOT_PASSWORD=pingxzxhfileoss123456" \
  -v /etc/localtime:/etc/localtime:ro \
  -v /mnt/data${i}:/data \
  -v /mnt/config${i}:/config \
  minio/minio:RELEASE.2022-01-08T03-11-54Z server /data     --console-address ":91${i}"
done
```

```
# minio_cluster_install sh
rm -rf /opt/minio/config /opt/minio/data1 /opt/minio/data2
mkdir -p /opt/minio/data1 /opt/minio/data2 /opt/minio/config
MINIO_HOST=192.168.56.105
docker run -it \
--net=host \
  -e "MINIO_ROOT_USER=pigx" \
  -e "MINIO_ROOT_PASSWORD=pingxzxhfileoss123456" \
-v /opt/minio/data1:/data1 \
-v /opt/minio/data2:/data2 \
-v /opt/minio/config:/root/.minio \
minio/minio:RELEASE.2022-01-08T03-11-54Z server -C=/root/.minio http://${MINIO_HOST}/data1 http://${MINIO_HOST}/data2 \
http://${MINIO_HOST}/data1 http://${MINIO_HOST}/data2
```

##### `一件部署`

```
docker-compose.yaml
docker-compose pull
docker-compose up -d
```

现在每个实例都可以访问，端口从 9001 到 9004，请在浏览器中访问http://127.0.0.1:9001/

```
version: '3.7'

# Settings and configurations that are common for all containers
x-minio-common: &minio-common
  image: quay.io/minio/minio:RELEASE.2022-01-08T03-11-54Z
  command: server --console-address ":9001" http://minio{1...4}/data{1...2}
  expose:
    - "9000"
    - "9001"
  environment:
    MINIO_ROOT_USER: admin
    MINIO_ROOT_PASSWORD: minio12345678
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
    interval: 30s
    timeout: 20s
    retries: 3

# starts 4 docker containers running minio server instances.
# using nginx reverse proxy, load balancing, you can access
# it through port 9000.
services:
  minio1:
    <<: *minio-common
    hostname: minio1
    volumes:
      - data1-1:/data1
      - data1-2:/data2

  minio2:
    <<: *minio-common
    hostname: minio2
    volumes:
      - data2-1:/data1
      - data2-2:/data2

  minio3:
    <<: *minio-common
    hostname: minio3
    volumes:
      - data3-1:/data1
      - data3-2:/data2

  minio4:
    <<: *minio-common
    hostname: minio4
    volumes:
      - data4-1:/data1
      - data4-2:/data2

  nginx:
    image: nginx:1.19.2-alpine
    hostname: nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "9000:9000"
      - "9001:9001"
    depends_on:
      - minio1
      - minio2
      - minio3
      - minio4

## By default this config uses default local driver,
## For custom volumes replace with volume driver configuration.
volumes:
  data1-1:
  data1-2:
  data2-1:
  data2-2:
  data3-1:
  data3-2:
  data4-1:
  data4-2:

```

### nacos 集群

#### 1.nacos 主启动类单节点改为 false

```
System.setProperty(ConfigConstants.STANDALONE_MODE, "false");
```

#### 2.如果用 idea 启动

复制启动配置添加端口，重写行参内添加端口 **server.port**

```
#这个方法将会获取你的user.home的路径
SystemUtil.getUserInfo().getHomeDir()
```

在需求路径下配置**/nacos/conf/cluster.conf** 这个文件

```
#ip ：port   配置IP于端口 如
127.0.0.1:8842
127.0.0.1:8840
127.0.0.1:8841
```

#### 3.因为使用了集群所以需要 nginx 来负载均衡

```
upstream serverList{
	server 127.0.0.1:8840;
	server 127.0.0.1:8841;
	server 127.0.0.1:8842;
}
server{
	listen 8848;
	server_name:localhost;
	location / {
			proxy_pass http://serverList;
			index index.html index.htm;
	}
}
```

### 定时任务的使用

#### 1.**引入依赖**

**在生成的项目工程内 pom.xml 里加入**

```
		<!--Job-->
		<dependency>
			<groupId>com.pig4cloud</groupId>
			<artifactId>pigx-common-job</artifactId>
		</dependency>
```

#### 2.可选

```
xxl:
  job:
    executor:
      appname: zxhDemoJob        #如果不配置则自动加载项目名称
      port: 6061  #通讯端口


```

#### 3.在生产的项目启动项内加入注解

```
@EnablePigxXxlJob
```

#### 4.代码范例 任务执行器

```
@Service
public class DemoJobService {
	@XxlJob("demoJob")
	public void demoJob(){
		XxlJobHelper.log("Hello xxhl-job");
	}
}
```

**启动服务** PigxJobAdminApplication :9080/

[任务调度中心](http://localhost:9080/xxl-job-admin/jobgroup) 账号密码 admin/123456

**编辑执行器** `AppName` 要于项目名一致 如`pigx-zxh-biz` 如果.yml 的 xxl:配置了则用 appname 内容

**OnLine 机器地址**选择自动的等待即可

**任务管理器** **JobHandler**必须于 @XxlJob("demoJob") 的内容保持一致.

### 整合 MQ

**docker 环境**

```
docker run -d -p 5672:5672 -p 15672:15672 --restart=always --name rabbitmq rabbitmq:management
```

- 默认用户名密码

  | 用户名 | 密码  |
  | :----- | :---- |
  | guest  | guest |

**代码整合**

- 目标服务增加 amqp 依赖

- ```java
    <dependency>
     <groupId>org.springframework.boot</groupId>
     <artifactId>spring-boot-starter-amqp</artifactId>
    </dependency>nacos 对应的服务配置文件增加链接相关信息
  ```

- nacos 对应的服务配置文件增加链接相关信息

- ```
  spring:
    rabbitmq:
      host: 10.30.94.33
      port: 5672
      username: guest
      password: guest
  ```

- 配置服务启动创建队列 hello

- ```java
  @Configuration(proxyBeanMethods = false)
  public class RabbitQueueConfiguration {
  
   /**
    * 启动时创建队列
    * @return
    */
   @Bean
   public Queue queue() {
    return new Queue("hello");
   }
  }
  ```

- 配置服务监听 hello 队列

```
@Component
public class RabbitQueueListener {

 /**
  * 监听 hello 队列的处理器
  * @param message
  */
 @RabbitListener(queues = "hello")
 @RabbitHandler
 public void onMessage(Message message) {
  log.info("消费端Payload: " + message.getPayload().toString());
 }
}
```

- 代码中向指定队列发送消息

```java
 @Autowired
 private AmqpTemplate amqpTemplate;

  amqpTemplate.convertAndSend("队列名称","信息");
```

### feign 调用使用说明

```xml
	<!--pigx-zxh-api pom  内引入 pixgx feign 工具类-->
		<dependency>
			<groupId>com.pig4cloud</groupId>
			<artifactId>pigx-common-feign</artifactId>
		</dependency>
```

```
#在类似的路径下新建XXservice文件
com/pig4cloud/pigx/zxh/api/feign
```

#### 提供接口的 Controller 需要标注内部使用需要添加

```
@Inner
```

**对外提供接口的 server 类加入注解 ** `文件在对应的api包下` 如：_pigx-zxh-api_

```java
#contextId声明bean的名字，name需要调用的服务名（某工程的pom内artifactId的值）fallback暂时可不写
@FeignClient(value = "remotDemoService",name ="pigx-zxh-biz")
```

如果是内部调用的需要加入参数 **@RequestHeader(SecurityConstants.FROM) String from**

```
#外部调用不需要 GetMapping 为Controller内的具体Mapping
@GetMapping("/fendemo/demo2/{username}")
R demo2(@PathVariable("username") String username, @RequestHeader(SecurityConstants.FROM) String from);
```

#### 如何调用

**使用的工程 pom.xml 内引用服务提供方的 groupId 、artifactId**

```xml
		<dependency>
			<groupId>com.pig4cloud</groupId>
			<artifactId>pigx-zxh-api</artifactId>
			<version>4.2.0</version>
		</dependency>
```

**然后就可以加入注解了**

```java
@RequiredArgsConstructor
```

代码实现

```java
private final RemotDemoService demoService;
#方法内使用即可
R r = demoService.demo2(username, SecurityConstants.FROM_IN);
```

#### **外部测试**

提供服务的 Controller

```java
#Class注解
@RequestMapping("/fendemo")
#Mothed注解
	@RequestMapping("/demo1/{username}")
	public R demo1(@PathVariable("username") String username) {
		return R.ok("有token:"+username);
	}
```

对外接口提供

```java
@Class
@FeignClient(contextId = "remotDemoService", name = "pigx-zxh-biz")
@Method
	@GetMapping("/fendemo/demo1/{username}")
	R demo1(@PathVariable("username") String username);

```

调用方

1.POM 引用

2.注解然后调用

```
@RequiredArgsConstructor
private final RemotDemoService remotDemoService;
public R demo1(@PathVariable("username") String username) {

		System.out.println("username = " + username);
		return remotDemoService.demo1(username);
	}
```

工具 **Postman**

[需要先拿到 token](http://10.30.94.33:9999/auth/oauth/token)

```javascript
#我的本地9999为getwary
http://10.30.94.33:9999/auth/oauth/token
```

```javascript
10.30.94.33:6070/usedemo/demo1/zxh
```

Params:` grant_type``password `

Harders:`Authorization` `Basic dGVzdDp0ZXN0`

body:`username` `admin` `password` `JFat0Zdc` `scope` `server`
