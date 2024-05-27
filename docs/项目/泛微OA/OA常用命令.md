# OA常用命令

### 常用打开目录

```shell
cat /app/weaver/ecology/WEB-INF/prop/weaver.properties
```

```shell
cat /app/weaver/ecology/WEB-INF/prop/weaver_new_session.properties
```

```shell
cat /app/weaver/EM7/work/config/application-custom.properties
```



### 常用查看日志

```shell
tail -200f /app/weaver/Resin/log/jvm-app-0.log
```

```shell
tail -200f  /app/weaver/EM7/work/logs/tomcatlog/catalina.out 
```



### 常用git clone

` #克隆OA 分支切换 testoa 目录输出为weaver`

```shell
git clone -b testoa http://zhouxianhai%40qq.com:zxh123456@10.30.30.77/root/oa-ecology.git weaver
```

` #克隆EM 分支切换 test 目录输出为默认`

```shell
git clone -b test http://zhouxianhai%40qq.com:zxh123456@10.30.30.77/root/oa-em.git
```



### Docker 

#### run

```shell
docker run -it -p 80:80 -p 9081:9081 -v /mnt/kubernetes/demo-project-oa-data-pvc-804c4eeb-0891-4067-bcdf-f04b594a30a8/ecology:/data/ecology -d fwoa/fwoatest:v1.06
```

#### tag

```shell
docker tag fwoa/fwoatest:v$v 10.30.30.171:10880/fwoa/fwoa:v$v
```

#### Harbor

```shell
  DOCKER_USERNAME="admin"
  DOCKER_PASSWORD="Harbor12345"
  docker login 10.30.30.171:10880 -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
```



### PORT对映关系

#### EM

| 服务器名/端口 | 8999  | 9090  | 5222  | 7070  | 9081  |
| ------------- | :---: | :---: | :---: | :---: | :---: |
| EM-0          | 32060 | 32062 | 32064 | 32066 | 32068 |
| EM-1          | 32061 | 32063 | 32065 | 32067 | 32069 |

![image-20210916170402864](C:\Users\xianhaizhou\AppData\Roaming\Typora\typora-user-images\image-20210916170402864.png)



### ldap 文件目录

``` 
E:\OA\OAwendang\周先海\文档\oa相关\LDAP\20211220
```

``` 
/app/weaver/ecology/classbean/com/weaver/integration/ldap/sync/oa
```

