# kafka

## 	简单说明什么是kafka

​		Apache kafka是消息中间件的一种，Kafka是一个分布式的，可划分的，冗余备份的持久性的日志服务.

消息队列满了，其实就是篮子满了， 放不下了，那赶紧多放几个篮子，其实就是kafka的扩容。



## kafka名词解释

**Broker**：	Kafka节点，一个Kafka节点就是一个broker，多个broker可以组成一个Kafka集群
**Topic**：		一类消息，消息存放的目录即主题，例如page view日志、click日志等都可以以topic的形式存在，Kafka集群能够同时负责多个topic的分发
**massage**： Kafka中最基本的传递对象。
**Partition**：topic物理上的分组，一个topic可以分为多个partition，每个partition是一个有序的队列
**Segment**：partition物理上由多个segment组成，每个Segment存着message信息
**Producer** : 生产者，生产message发送到topic
**Consumer** : 消费者，订阅topic并消费message, consumer作为一个线程来消费
**Consumer Group**：消费者组，一个Consumer Group包含多个consumer
**Offset**：偏移量，理解为消息partition中的索引即可

**重topic**

- 整个broker,一句topic来进行消息中专,在重topic的消息队列里必然需要topic的存在

**轻topic**

- topic只是一种中转模式.

**无broker**

- 在生产者和消费者之间没有使用broker,例如zeroMQ,直接使用socket进行通信.





## 消息队列的流派

目前消息队列的中间件选型有很多种:

- rabbitMQ:功能非常强

- rocketMQ:性能比肩kafka
  - kafka:全球消息处理最快的一款MQ
- zeroMQ:



## Kafka的优势如下

​    **高吞吐量、低延迟：**kafka每秒可以处理几十万条消息，它的延迟最低只有几毫秒；

​    **可扩展性：**kafka集群支持热扩展；

​    **持久性、可靠性：**消息被持久化到本地磁盘，并且支持数据备份防止数据丢失；

​    **容错性：**允许集群中节点故障（若副本数量为n,则允许n-1个节点故障）；

​    **高并发：**支持数千个客户端同时读写。





## Kafka适合以下应用场景：

​	**日志收集：**				一个公司可以用Kafka可以收集各种服务的log，通过kafka以统一接口服务的方式开放给各种consumer；

​    **消息系统：**				解耦生产者和消费者、缓存消息等；

​    **用户活动跟踪：**		kafka经常被用来记录web用户或者app用户的各种活动，如浏览网页、搜索、点击等活动，这些活动信息被各个服务器发布到kafka的topic中，然后消费者通过订阅这些topic来做实时的监控分析，亦可保存到数据库；

​    **运营指标：**				kafka也经常用来记录运营监控数据。包括收集各种分布式应用的数据，生产各种操作的集中反馈，比如报警和报告；

​    **流式处理：**				比如spark streaming和storm。

## KAFKA的基本知识

#### 1.kafka的安装

##### 部署一台zookeeper服务器

- **准备工作**

将它部署在 /usr/local/zookeeper 目录下：

```
cd /usr/local && mkdir zookeeper && cd zookeeper
```

创建data目录，用于挂载容器中的数据目录：

```
mkdir data
```

- **Docker部署命令：**

```
docker run -d -e TZ="Asia/Shanghai" -p 2181:2181 -v $PWD/data:/data --name zookeeper --restart always zookeeper
```

- **命令详细说明：**

  ```
  -e TZ="Asia/Shanghai" # 指定上海时区 
  -d # 表示在一直在后台运行容器
  -p 2181:2181 # 对端口进行映射，将本地2181端口映射到容器内部的2181端口
  --name # 设置创建的容器名称
  -v # 将本地目录(文件)挂载到容器指定目录；
  --restart always #始终重新启动zookeeper
  ```

  **查看命令**（STATUS）为Up，说明容器已经启动成功

  ```
  docker ps -a
  ```

  **使用ZK命令行客户端链接**

  ```
  docker run -it --rm --link zookeeper:zookeeper zookeeper zkCli.sh -server zookeeper
  ```

  说明：`-server zookeeper`是启动`zkCli.sh`的参数

  ```
  [zk: zookeeper(CONNECTED) 0] ls /
  [admin, brokers, cluster, config, consumers, controller_epoch, isr_change_notification, latest_producer_id_block, log_dir_event_notification, zookeeper]
  [zk: zookeeper(CONNECTED) 1] 
  ```

  输入ls /可以查看当前链接

##### 安装JDK

```
tar zxf jdk-8u211-linux-x64.tar.gz -C /usr/local/
vim /etc/profile            # 编辑Java变量

export JAVA_HOME=/usr/local/jdk1.8.0_211
export JRE_HOME=/usr/local/jdk1.8.0_211/jre
export CLASSPATH=$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
```

```
source /etc/profile           # 执行使配置生效
java -version                # 查看是否安装成功
java version "1.8.0_211"
Java(TM) SE Runtime Environment (build 1.8.0_211-b12)
Java HotSpot(TM) 64-Bit Server VM (build 25.211-b12, mixed mode)
```

##### 下载kafka

[kafka下载地址](https://kafka.apache.org/downloads)

```
https://kafka.apache.org/downloads
```

```
tar zxf kafka_2.11-2.4.1.tgz -C /usr/local/
```

kafka在启动服务之前必须要设定3个参数:`config/server.properties` *文件内*

*broker.id、log.dirs、zookeeper.connect*

​		在Kafka集群中，每个broker都有一个唯一的id值用来区分彼此。Kafka在启动时会在zookeeper中/brokers/ids路径下创建一个与当前broker的id为名称的虚节点，Kafka的健康状态检查就依赖于此节点。当broker下线时，该虚节点会自动删除，其他broker或者客户端通过判断/brokers/ids路径下是否有此broker的id来确定该broker的健康状态。

​		Kafka broker的id值必须大于等于0时才有可能正常启动，但是这里并不是只能通过配置文件config/server.properties来修改这个值，还可以通过meta.properties文件或者自动生成功能来实现broker的id值的设置

*meta.properties文件中的内容参考如下*

```
#
#Sun May 27 23:03:04 CST 2018
version=0
broker.id=1
```

> Kafka服务启动时也会加载配置文件config/server.properties里的参数log.dir和log.dirs，这两个参数用来配置Kafka日志文件所存放的根目录。一般情况下，log.dir用来配置单个根目录，log.dirs用来配置多个根目录，但是Kafka并没有对此做强制性限制，也就是说log.dir和log.dirs都可以用来配置单个或者多个根目录。log.dirs的优先级比log.dir高，如果没有配置log.dirs则才以log.dir配置的为准。默认情况下只配置了log.dir参数，其值为/tmp/kafka-logs。

**meta.properties文件与broker.id的关联如下：**

1. 如果log.dir或log.dirs中配置了多个根目录，那么这些根目录中的meta.properties文件所配置的broker.id不一致的话则会报出InconsistentBrokerIdException的异常。
2. 如果config/server.properties配置文件里配置的broker.id的值和meta.properties文件里的broker.id的值不一致的话，同样会报出InconsistentBrokerIdException的异常。
3. 如果config/server.properties配置文件中并未配置broker.id的值，那么就以meta.properties文件中的broker.id为准。
4. 如果没有meta.properties文件，那么在获取到合适的broker.id值之后会创建一个新的meta.properties文件并将broker.id的值存入其中。
   

##### Socket Server Settings

设置当前主机的地址： listeners = PLAINTEXT://your.host.name:9092

```
listeners=PLAINTEXT://192.168.56.104:9092
```

##### Log Basics 日志默认保存7天

```
# A comma separated list of directories under which to store log files
log.dirs=/usr/local/kafka/data/kafka-logs
```

##### Zookeeper 需要设置消费者

```
zookeeper.connect=192.168.56.105:2181
```

##### 启动命令

需要先安装JDK 和启动zookeeper

```
#先进入bin目录
cd /usr/local/kafka/bin
./kafka-server-start.sh -daemon ../config/server.properties 
```

```
"-daemon" 参数代表以守护进程的方式启动kafka server。
```

​		*官网及网上大多给的启动命令是没有"-daemon"参数，如：“bin/kafka-server-start.sh config/server.properties &”，但是这种方式启动后，如果用户退出的ssh连接，进程就有可能结束，具体不清楚为什么。*

查看是否运行：

```
ps -aux |grep server.properties
```

**此时看zookeeper就多了内容了**

```
[zk: zookeeper(CONNECTED) 3] ls /
[admin, brokers, cluster, config, consumers, controller, controller_epoch, isr_change_notification, latest_producer_id_block, log_dir_event_notification, zookeeper]
[zk: zookeeper(CONNECTED) 4] ls brokers/
Path must start with / character
[zk: zookeeper(CONNECTED) 5] ls /brokers
[ids, seqid, topics]
[zk: zookeeper(CONNECTED) 6] ls /brokers/ids
[0]
```

brokers/ids/0  的Kafka已经上线了

#### 2.创建**topic**

创建“test” 的topic 只有一个partition,备份因子设置为1：

- 通过kafka命令向zk中创建一个主题

```
bin/kafka-topics.sh --create --zookeeper 192.168.56.105:2181 --replication-factor 1 --partitions 1 --topic test
```

```
## topic列表查询
bin/kafka-topics.sh --zookeeper 192.168.56.105:2181 --list
```

#### 3.生产消息

```
./kafka-console-producer.sh --broker-list 192.168.56.104:9092 --topic test
```

#### 4.消费消息

- 方式一：从最后一条消息的偏移量+1开始消费

```
./kafka-console-consumer.sh --bootstrap-server 192.168.56.104:9092 --topic test
```

- 从头开始消费


```
./kafka-console-consumer.sh --bootstrap-server 192.168.56.104:9092 --from-beginning --topic test
```

#### 5.关于消息的细节

- 生产者将消息发送给broker，broker会将消息保存在本地日志文件中

  ```
  /usr/local/kafka/data/kafka-logs/主题-分区/0000.log
  ```

- 消息是有序保存的，通过offset便宜量来描述消息的有序性

- 消费者消费消息时通过offset来描述当前要消费的那条消息的位置



#### 6.单播消息

多个消费者在同一个消费组,只有1个消费覅这能订阅toPic中的消息.

```
./kafka-console-consumer.sh --bootstrap-server 192.168.56.104:9092 --consumer-property group.id=testGroup --topic test
```



#### 多播消息

不同的消费者组订阅同一个topic,不同的消费组中只有1个消费组能收到消息.

```
./kafka-console-consumer.sh --bootstrap-server 192.168.56.104:9092 --consumer-property group.id=testGroup1 --topic test
```

```
./kafka-console-consumer.sh --bootstrap-server 192.168.56.104:9092 --consumer-property group.id=testGroup2 --topic test
```

查看某一个消费者组的信息

```
bin/kafka-consumer-groups.sh --bootstrap-server 192.168.56.104:9092 --list
```

```
./kafka-consumer-groups.sh --bootstrap-server 192.168.56.104:9092 --describe --group testGroup1
```

查消费组组当前消费的信息

```
[root@k8s-node5 bin]# ./kafka-consumer-groups.sh --bootstrap-server 192.168.56.104:9092 --describe --group testGroup1
Consumer group 'testGroup1' has no active members.
GROUP           TOPIC    PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG   CONSUMER-ID     HOST        CLIENT-ID
testGroup1      test       0          38              38              0      -           -           -
```

- **CURRENT-OFFSET:**最后被消费的消息的偏移量.
- **LOG-END-OFFSET:**最后一条消息的偏移量(消息总量).
- **LAG:**挤压了多少条消息.



## KAFKA中主题和分区的概念

#### 1.主题Topic

kafka通过topic将消息进行分类,不同的topic会被该topic的消费者消费.

Partition是为了解决log文件过大的问题.

#### 2.分区Partition

- 分区存储,可以解决统一文件存过大的问题.

- 分布式存储消息及消费消息

#### **3.创建分区的主题**

```
./kafka-topics.sh --create --zookeeper 192.168.56.105:2181 --replication-factor 1 --partitions 2 --topic test1
```

4.消息日志文件中保存的内容

- 00000.log:这个文件就是保存的消息
- _consumer_offsets-49:
  - kafka内部自己创建了_consumer_offsets主题包含了50个分区,这个主题是用来存放消费者消费某个主题的偏移量.
  - 每个消费者把消费的主题偏移量主动上报给kafka的默认主题_consumer_offsets
  - 为了提高并发性,默认设置了50个分区.
  - 通过hash函数计算提交哪个分区:hash(consumerGroupid)%_consumer_offsets主题的分区数
  - 内容是:key是consumerGroupID+topic+分区号,value就是当前offset的值
- 分区默认保存消息时间为7天.



### kafka集群搭建

准备3个server.properties

server.properties

```
broker.id=0
listeners=PLAINTEXT://192.168.56.104:9092
log.dirs=/usr/local/kafka/data/kafka-logs
```

server1.properties

```
broker.id=1
listeners=PLAINTEXT://192.168.56.104:9093
log.dirs=/usr/local/kafka/data/kafka-logs-1
```

server2.properties

```
broker.id=2
listeners=PLAINTEXT://192.168.56.104:9094
log.dirs=/usr/local/kafka/data/kafka-logs-2
```

启动服务

```
#先进入bin目录
cd /usr/local/kafka/bin
./kafka-server-start.sh -daemon ../config/server.properties 
./kafka-server-start.sh -daemon ../config/server1.properties 
./kafka-server-start.sh -daemon ../config/server2.properties 
```

#### 副本创建

在集群中，不同的副本会被部署在不同的broker上，下面创建1个主题，2个分区，3个副本

```
./kafka-topics.sh --create --zookeeper 192.168.56.105:2181 --replication-factor 3 --partitions 2 --topic my-replicated-topic-test	
```

在kafka服务器查看zookeeper

```
#查看topic情况 zookeeper服务器
./kafka-topics.sh --describe --zookeeper 192.168.56.105:2181 --topic my-replicated-topic-test
```

通过zookeeper中查看 ls /broker/ids   内有几个

```
docker run -it --rm --link zookeeper:zookeeper zookeeper zkCli.sh -server zookeeper
```

副本是为主题中的分区创建多个备份，多个副本在集群中多个brokerzhong ,会有一个副本作为leader，其他是follower。

- **leader**：kafka写和读都发生在leader上,leader负责同步到其他follower上，当leader挂了经过主从选举选举新的leader
- **follower：**接受leader的同步数据
- **isr:**可以同步和已经同步的节点会记录在内。弱节点太差同步更不上会被踢出。

这些副本leader表示在哪个节点，Replicas是表示有多少个副本，ISR表示同步完成的副本，

![image-20220122171912887](C:\project\kafuka\kafkaimages\image-20220122171912887.png)



kafka集群发送消息

```
./kafka-console-producer.sh --broker-list 192.168.56.104:9092,192.168.56.104:9093,192.168.56.104:9094 --topic my-replicted-topic-test
```

kafka集群消息的消费

```
./kafka-console-consumer.sh --bootstrap-server 192.168.56.104:9092,192.168.56.104:9093,192.168.56.104:9094 --from-beginning  --topic my-replicted-topic-test
```

![image-20220123150257130](C:\project\kafuka\kafkaimages\image-20220123150257130.png)

一个partition智能被一个消费组里的某一个消费者消费，从而保证消费顺序，Kafka只在partition的泛微内保证消息消费的局部顺序性，不能在同一个topic中的多个partition中保证总的消费顺序性。

一个消费者可以消费多个partition。消费组中消费者的数量不能比一个topic中的partition多，否则多出来的消费者消费不到消息。

**向集群发消息**

```
./kafka-console-consumer.sh --bootstrap-server 192.168.56.104:9092 --consumer-property group.id=testGroup2 --topic test
```

消费集群消息

```
./kafka-console-consumer.sh --bootstrap-server 192.168.56.104:9092,192.168.56.104:9093,192.168.56.104:9094 --from-beginning  --topic my-replicted-topic-test
```

指定消费者组消费消息

```
./kafka-console-consumer.sh --bootstrap-server 192.168.56.104:9092,192.168.56.104:9093,192.168.56.104:9094 --from-beginning --consumer-property group.id=testGroup1 --topic my-replicted-topic

```

### 生产者发送消息的JAVA基本实现

版本要与下载的版本一致

```java
		<dependency>
			<groupId>org.apache.kafka</groupId>
			<artifactId>kafka-clients</artifactId>
			<version>2.4.1</version>
		</dependency>
```

```
		Properties props = new Properties();
		props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "192.168.56.104:9092,192.168.56.104:9093,192.168.56.104:9094");
		props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
		props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
		Producer<String, String> producer = new KafkaProducer<String, String>(props);

		ProducerRecord<String, String> producerRecord = new ProducerRecord<String, String>(TOPIC_NAME, 1,"mykeyvalue", "helloKafka");

		RecordMetadata recordMetadata = producer.send(producerRecord).get();
		System.out.println("同步发送结果：topic=" + recordMetadata.topic() + "|partition-" + recordMetadata.partition() + "|offset-" + recordMetadata.offset());
```

