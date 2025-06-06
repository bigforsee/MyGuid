## 安装mysql8

### 1.下载MySQL安装脚本

```shell
wget  http://dl.qiyuesuo.com/private/mysql/mysqlinstall.sh
```

### 2.执行脚本（5.7使用1，8.0使用2）

```shell
/bin/bash mysqlinstall.sh 2
```

### 3.输入自定义MySQL安装路径，默认为/mysql， 如果指定的目录不存在则自动创建(最好由脚本自动创建或者保证指定的目录为一个空目录)

```shell
/mysql
```

### 4.指定root用户密码，至少8位，至少包含大小写字母、数字、特殊字符中的三者（否则之后重启数据库会提示密码错误无法登录） 如果出现此问题请参考知识树[修改密码]()

```shell
Root@123
```

### 5.安装成功 ，请根据服务器磁盘类型优化/etc/my.cnf文件末尾的innodb_io_capacity和innodb_io_capacity_max参数

```config
# innodb_io_capacity_max一般设置为innodb_io_capacity的2倍，对于SSD硬盘，innodb_io_capacity可以设置8000更高甚至上万的值，对于普通SAS硬盘，可设置200，对于sas raid10可设置2000，对于fusion-io闪存设备可设置几万以上，注意：此参数对于数据库性能影响很大，根据实际磁盘类型进行调整。
```

### 6.改完参数后重启数据库服务，至此安装结束

```shell
systemctl restart mysqld
```

### 7.改完参数后重启数据库服务，至此安装结束

```mysql
mysql -uroot -pRoot@123
create user 'root'@'10.30.94.45' identified by 'Root@123';
grant all privileges on *.* to 'root'@'10.30.94.45' with grant option;
flush privileges;
```

create user 'root'@'10.30.30.112' identified by 'Root@123';



## 包安装MYSQL8.0

```shell
wget https://www.gitlink.org.cn/attachments/entries/get_file?download_url=https://www.gitlink.org.cn/api/lengleng/mirror/raw/mysql80-community-release-el7-11.noarch.rpm?ref=master -O mysql80-community-release-el7-7.noarch.rpm

rpm -ivh mysql80-community-release-el7-7.noarch.rpm

yum install -y mysql mysql-server

# 修改配置文件
vim /etc/my.cnf
lower_case_table_names=1

# 重启mysql
systemctl restart mysqld

# 查看默认密码 (注意复制全了很多特殊字符)
grep password /var/log/mysqld.log

# mysql client 链接 mysql
mysql -uroot -p

# 修改默认密码为 root
alter user 'root'@'localhost' identified by 'ZxcRoot123!@#';
set global validate_password.check_user_name=0;
set global validate_password.policy=0;
set global validate_password.length=1;
alter user 'root'@'localhost' identified by 'root';

# 修改为允许远程访问
use mysql;
update user set host = '%' where user = 'root';
FLUSH PRIVILEGES;
```

