## git安装

**进入git 在GitHub上发布版本页面https://github.com/git/git/releases**



## Linux 部署

### 1.进入目录

```shell
cd /usr/local 
```

###  2.上传文件至目录

> 如果rz提示 -bash: rz: 未找到命令，输入如下命令安装lrzsz，安装后即可使用rz命令

```shell
tar -zxvf git-2.38.1.tar.gz
```



### **3.进入到解压后的文件夹**

```shell
cd /usr/local/git-2.38.1
```



### **4.**安装依赖

**安装解压后的源码需要编译源码，不过在此之前需要安装编译所需要的依赖。**

```shell
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker -y
```



### **5.**卸载这个旧版

**提示，安装编译源码所需依赖的时候，yum自动帮你安装了git，这时候你需要先卸载这个旧版的git**

```shell
yum -y remove git
```



### 6.**编译git源码**

```shell
make prefix=/usr/local/git all
```



### 7.**安装git至/usr/local/git路径**

```shell
make prefix=/usr/local/git install
```



### 8.**配置环境变量**

```shell
vi /etc/profile
```

> **在最底部加上，( 输入 :wq! 保存修改)**

```shell
export PATH=$PATH:/usr/local/git/bin
```



### 9.**刷新环境变量**

```shell
source /etc/profile
```

### 10.**查看Git是否安装完成**

```shell
git --version
```

**到这里，从github上下载最新的源码编译后安装git完成**



## K8S部署
 - [gitlab-postgresql.yaml](gitlab/gitlab-postgresql.yaml) 

 - [gitlab-pvc.yaml](gitlab/gitlab-pvc.yaml) 

 - [gitlab-redis.yaml](gitlab/gitlab-redis.yaml) 

 - [gitlab.yaml](gitlab/gitlab.yaml) 

```shell
```

