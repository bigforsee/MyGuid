# Docker-compose 部署 Jenkins

[官网](www.jenkins.io)

## 在download里找到 `LTS` 长期维护版标识 如：

**Download Jenkins 2.401.1 LTS for:**

## 拉去镜像

```shell
docker pull jenkins/jenkins:2.401.1-lts
```



## 编写docker-compose.yml文件

vi docker-compose.yml

```yml
version: "3.1"
services:
  jenkins:
    image: jenkins/jenkins:2.401.1-lts
    container_name: jenkins
    ports:
      - 8080:8080
      - 50000:50000
    volumes:
      - ./data/:/var/jenkins_home/
```



说明：这个文件所在的目录会生成一个data的目录，需要对他赋权

```shell
mkdir data
chmod 777 -R data
#开始部署
docker-compose up -d
查看日志
docker logs -f  jenkins
```

注意打印的密码：

*************************************************************
*************************************************************
*************************************************************

Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

2ab58ee5eb9543d7814860c3cb8fe028

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword

*************************************************************
*************************************************************
*************************************************************



- 启动成功后等待 浏览Ip:8080  可以输入密码后输入刚才得到的密码

- 安装插件  点击选择插件来安装    点击安装即可，可以后期在安装

​	    因为网络问题安装插件会失败  可以去官网  找到plugins 查找需要的插件下载

​        还是不行就需要 修改数据卷中的 `hudson.model.UpdataCenter.xml` 文件

​		如url  替换为 `http://mirror.esuni.jp/jenkins/updates/update-center.json`

- 没有完成可以可以点继续，然后输入登录账号密码 如：root:root



Timestamper  Build Timeout  Credentials Binding  Workspace Cleanup  Mailer  Mailer  Pipeline  Git  Pipeline: GitHub Groovy Libraries  GitHub Branch Source  SSH Build Agents  LDAP Email Extension

## 配置java

- 先下载 Linux版本的jdk  apache maven
- 放到jenkins的宿主机的挂载目录
- 解压名修改jdk    maven 
- 插件内配置容器内的目录  /var/jenkins_home/jdk   /var/jenkins_home/maven

安装了 `publish-over-ssh`   插件后可以在系统配置里面配置SSH







拉项目时工程目录 `workspace`