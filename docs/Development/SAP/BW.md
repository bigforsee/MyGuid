## BW配置

| 描述      | bwd(开发)     | bwq(测试)   | bwp(生产)      |
| --------- | ------------- | ----------- | -------------- |
| 组/服务器 | 10.30.30.49   | 10.30.30.49 | 10.30.30.83    |
| 实例      | 00            | 02          | 00             |
| 标识      | BWD           | BWQ         | BWP            |
| 客户端    |               |             |                |
| 账号密码  | TEST1／QWE123 | QZHOUXH     | ZHOUXH/TZHOUXH |

- 

SAP事务码

rsa1



包

![image-20240514085021477](images\BW包.png)



BWDK902884 我的请求号

特征、指标 Name Z





su01

用altmodule

Z68(固定)I(层级)SD(模块)





rsa5

SAP预定的数据源  必须要激活才可以用

激活后可以在RSA６看到



LBWQ

监控数据运行的情况

LBWE

作业控制



SBIW 抽数





![image-20240514105255244](images\信息范围.png)

![image-20240514105316137](images\对象目录.png)

为数据源做准备

![image-20240514105626388](images\应用程序主键.png)



解锁 SM12 输入自己的账号



rso2找自定义表  如ZVMM002 查看db视图zvmm002(最好从视图中提取数据)



sm59 数据源链接配置







![image-20240522162813458](images\DataStory Object)

