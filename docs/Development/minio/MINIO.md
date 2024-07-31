# MINIO部署

## docker部署

```shell
# 9000  端口是API 通信端口， 9001 是web管理台地址 MINIO_ROOT_USER 账号 MINIO_ROOT_PASSWORD 密码 /data 服务内部存储根目录
rm -rf  /mydata/minio/data /mydata/minio/config
mkdir -p /mydata/minio/data /mydata/minio/config
docker run -d -p 9000:9000 -p 5001:5001 -p 9090:9090 --name minio \
  -e "MINIO_ROOT_USER=admin" \
  -e "MINIO_ROOT_PASSWORD=minio@HBsn" \
  -v /mydata/minio/data:/data \
  -v /mydata/minio/config:/config \
  minio/minio:RELEASE.2021-08-25T00-41-18Z.fips server /data --console-address ":5001"
  
  sudo docker update minio --restart=always
```



2、下载Minio镜像

| 命令                                                      | 描述                                                         |
| --------------------------------------------------------- | ------------------------------------------------------------ |
| docker pull minio/minio                                   | 下载最新版Minio镜像 (其实此命令就等同于 : docker pull minio/minio:latest ) |
| docker pull minio/minio:RELEASE.2022-06-20T23-13-45Z.fips | 下载指定版本的Minio镜像 (xxx指具体版本号)                    |
|                                                           |                                                              |

新版本

```shell
# 9000  端口是API 通信端口， 9001 是web管理台地址 MINIO_ROOT_USER 账号 MINIO_ROOT_PASSWORD 密码 /data 服务内部存储根目录
mkdir -p /mydata/minio/data /mydata/minio/config
docker run -p 9000:9000 -p 9090:9090 \
     --net=host \
     --name minio \
     -d --restart=always \
     -e "MINIO_ACCESS_KEY=admin" \
     -e "MINIO_SECRET_KEY=minio@HBsn" \
     -v /home/minio/data:/data \
     -v /home/minio/config:/root/.minio \
     minio/minio server \
     /data --console-address ":9090" -address ":9000"
```

