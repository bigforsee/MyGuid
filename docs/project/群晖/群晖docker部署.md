# docker 镜像加速地址

https://rr05efme.mirror.aliyuncs.com

矿神套件

https://spk7.imnks.com

```shell
#安装ddnsgo解析ip与域名绑定
```



PIGX minio部署

```shell
# 注意版本号，此版本为 Apache 2.0 协议可以商用
docker run -dit -p 9000:9000 -p 9090:9090 --name minio1 \
  -v /volume2/docker/minio/data:/data           \
  -v /volume2/docker/minio/conf:/etc/config.env         \
  -e "MINIO_CONFIG_ENV_FILE=/etc/config.env"    \
  -e "MINIO_ROOT_USER=lengleng" \
  -e "MINIO_ROOT_PASSWORD=lengleng" \
  minio/minio:RELEASE.2021-04-22T15-44-28Z  server /data
```





pigx-register

```shell
docker run -dit --net=host --name pigx-register \
-e "NACOS_HOST=192.168.2.110" \
-e "MYSQL_HOST=192.168.2.110" \
-e "MYSQL_MONITOR=192.168.2.110" \
www.xianhai.online:10881/repo/pigx-register:v1.0.2
```



pigx-upms-biz

```shell
docker run -dit --net=host --name pigx-upms-biz  \
-e "NACOS_HOST=192.168.2.110" \
-e "MYSQL_HOST=192.168.2.110" \
www.xianhai.online:10881/repo/pigx-upms-biz:v1.0.2
```



pigx-gateway

```shell
docker run -dit --net=host --name pigx-gateway  \
-e "NACOS_HOST=192.168.2.110" \
-e "MYSQL_HOST=192.168.2.110" \
www.xianhai.online:10881/repo/pigx-gateway:v1.0.2
```



pigx-auth

```shell
docker run -dit --net=host --name pigx-auth  \
-e "NACOS_HOST=192.168.2.110" \
-e "MYSQL_HOST=192.168.2.110" \
www.xianhai.online:10881/repo/pigx-auth:v1.0.2
```



pigx-codegen

```shell
docker run -dit --net=host --name pigx-codegen  \
-e "NACOS_HOST=192.168.2.110" \
-e "MYSQL_HOST=192.168.2.110" \
www.xianhai.online:10881/repo/pigx-codegen:v1.0.2
```







 pigx-monitor部署

```shell
docker run -dit --net=host --name pigx-monitor \
-e "NACOS_HOST=192.168.2.110" \
-e "MYSQL_HOST=192.168.2.110" \
www.xianhai.online:10881/repo/pigx-monitor:v1.0.2
```



蒲公英vpn

```shell
docker run -dit  --net=host --restart=always --name naspgy \
-e "PGY_USERNAME=2896672:002" \
-e "PGY_PASSWORD=zxh123456" \
bestoray/pgyenterprise:latest
```



虚拟机

```shell
ubuntu docker/zxh@12239
```

一键部署开发环境

vi docker.ini.sh  i 输入下面内容后:wq!  chmod +x docker.ini.sh 

```
#!/bin/bash
# 安装 Docker 和 Docker Compose 的一键脚本 - 自动判断系统

# 检测当前操作系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "无法检测到你的操作系统。"
    exit 1
fi

# 根据操作系统执行相应的安装步骤
case $OS in
    centos)
        echo "检测到 CentOS 系统，开始安装 Docker 和 Docker Compose..."

        # 更新系统
        sudo yum update -y

        # 安装所需的依赖
        sudo yum install -y yum-utils device-mapper-persistent-data lvm2

        # 添加 Docker 仓库
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

        # 安装 Docker
        sudo yum install -y docker-ce docker-ce-cli containerd.io

        # 启动 Docker 服务
        sudo systemctl start docker

        # 设置 Docker 开机自启
        sudo systemctl enable docker
        ;;
    ubuntu)
        echo "检测到 Ubuntu 系统，开始安装 Docker 和 Docker Compose..."

        # 更新系统
        sudo apt-get update -y

        # 安装所需的依赖
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

        # 添加 Docker 的 GPG 密钥
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

        # 添加 Docker 仓库
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

        # 更新系统
        sudo apt-get update -y

        # 安装 Docker
        sudo apt-get install -y docker-ce
        ;;
    *)
        echo "暂不支持你的操作系统：$OS"
        exit 1
        ;;
esac

# 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 设置可执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 输出版本信息以验证安装成功
echo "Docker version:"
docker --version
echo "Docker Compose version:"
docker-compose --version
```

