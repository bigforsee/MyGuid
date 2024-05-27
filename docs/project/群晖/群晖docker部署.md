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

