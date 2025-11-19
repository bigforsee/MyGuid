# PI 配置接口手册

## 一.地址

[测试服](http://10.30.30.60:50200/dir/start/index.jsp)





## 下载ESR IB

打开测试服地址，点击下载的内容后打开

![image-20230830082437748](/Users/zhouxianhai/project/sap/pi/images/image-20230830082437748.png)

 

> 打开时提示使用打开的程序  

![image-20230830084951388](/Users/zhouxianhai/project/sap/pi/images/image-20230830084951388.png)



## 快速查找

![image-20230830082732631](/Users/zhouxianhai/project/sap/pi/images/image-20230830082732631.png)



![image-20230830093254711](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830093254711.png)



创建namespaces



![image-20230830095041947](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830095041947.png)



需要准备  data type.     M

```text
PRDelete
http://hb30.com/mm/PRDelete

DT_TESTZHOUXH001_Req
DT_TESTZHOUXH001_Resp

MT_TESTZHOUXH001_Req
MT_TESTZHOUXH001_Resp

SI_TESTZHOUXH001_is
SI_TESTZHOUXH001_os

MM_TESTZHOUXH001_Req
MM_TESTZHOUXH001_Resp

OM_TESTZHOUXH001

SC_1011_MM_PRDelete
CC_1011_PRDelete_Soap_Sender
CC_1011_PRDelete_Rest_Sender

http://podqapp.hb30.com:50000/dir/wsdl?p=ic/f768543587ef3ae6ab10f819e0fb46c0
```



新增字段

![image-20230830100311949](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830100311949.png)



选择字段类型

![image-20230830100649527](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830100649527.png)



![image-20230830100432786](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830100432786.png)

选择是否必填

![image-20230830100457790](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830100457790.png)

子表设置  要选择 unbounded

![image-20230830101002880](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830101002880.png)



### new -> interface-message type

![image-20230830102318095](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830102318095.png)

### 选择对应的内容

![image-20230830102516988](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830102516988.png)



创建接口服务

![image-20230830102956908](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830102956908.png)

![image-20230830103637482](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830103637482.png)

![image-20230830103740328](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830103740328.png)



![image-20230830103315128](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830103315128.png)



MM

![image-20230830103829390](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830103829390.png)



![image-20230830104534794](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830104534794.png)



如果2边是一样的就可以一次全部映射

![image-20230830104613019](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830104613019.png)



### 新建OM

![image-20230830105149396](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830105149396.png)

![image-20230830105323365](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830105323365.png)

保存后选择

![image-20230830105452595](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830105452595.png)



激活更改内容

> 不激活IB无法看到内容

![image-20230830110334626](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830110334626.png)

# 新建SC

> 打开IB

![image-20230830105954678](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830105954678.png)























## 解锁

![image-20230830101825206](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830101825206.png)



![image-20230830102014632](/Users/zhouxianhai/Library/Application Support/typora-user-images/image-20230830102014632.png)
