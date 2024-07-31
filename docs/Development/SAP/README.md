# 一.系统信息

## 配置

| 描述   | S4C(501)    | S4Q(500)    | S4D(200)    | S4P(800)    | SP2(900)    |
| ------ | ----------- | ----------- | ----------- | ----------- | ----------- |
| 服务器 | 10.30.30.90 | 10.30.30.55 | 10.30.30.48 | 10.30.30.82 | 10.30.30.85 |
| 实例   | 00          | 00          | 00          | 00          | 00          |
| 标识   | S4C         | S4Q         | 54D         | S4P         | SP2         |

账号密码： 
200： ZHOUXH
300： TZHOUXH
500： QZHOUXH
初始密码都是zxh123456
BWD  TEST1	    QWE123

800
sn0369/Lby13273!
it0003/Fm@hb30.com

说明：
	200是开发环境和300是在一起的，只需要修改集团就可以切换200 300 系统
	300是软件代码测试环境
	500是实施测试环境



### PI

开发环境：zhouxh /zxh123	http://10.30.30.60:50000/dir/start/index.jsp
测试环境：zhouxh /zxh456	http://10.30.30.60:50200/dir/start/index.jsp
生产环境：zhouxh/zxh123         http://10.30.30.63:50000/dir/start/index.jsp


javaws -verbose repository.jnlp    pi   Java 打不开时用这个方法打开 ，首先需要配置Java环境



http://10.30.30.78:81/svn/三宁SAP/
工号	12239 12239@hb30.com

BW学习视频
http://list.youku.com/albumlist/show/id_18879449.html?ascending=0&refer=qita_market.qrwang_00003026_000000_ZNf6ji_19041800

### 字段自动提示代码的设置

[设置方法](https://www.cnblogs.com/imimjx/p/13087373.html)

## 基础知识

### 1.数据类型

```abap
C  字符类型
N  数字字符类型 
I  整数类型
String 字符串
P 带小数的数字
F 浮点类型
D 日期类型
T  时间类型
```



### 2.消息类型

```abap
S   success   成功
E   Error  错误
W  Warning 警告
I   Information 信息
A  Abend 立即终止
X  Dump
```



### 3.条件语句

```abap
IF条件语句
IF ...

ELSEIF ...

ELSEIF...

ELSE.

ENDIF.



CASE条件语句
CASE 'X'.
  WHEN A.

  WHEN B.
	
  WHEN OTHERS.

ENDCASE.
```



### 4.循环语句

```abap
LOOP AT <内表> INTO <工作区>.

ENDLOOP.


DO 10 TIMES.

ENDDO.


WHILE <条件>.

ENDWHILE.
```



### 5.数据库语句

```abap
更新
UPDATE  <DB TABLE> FROM <IT_TABLE>.
UPDATE <DB_TABLE> SET  field1 = ...
                                          field2 = ...
                              WHERE key1 = ...
                                          key2 = ... .

创建
INSERT <DB_TABLE> FROM <IT_TABLE>.

删除
DELETE <DB_TABLE> FROM <IT_TABLE>.

更新/创建
MODIFY <DB_TABLE> FROM <IT_TABLE>.
```



### 6.表定义

```abap
内表	it_
工作群	wa_
导入参数命名  IV（inmport value）
```

### 7.数据字典SE11

```abap
事务代码:数据字典->SE11
MARA	物料主数据
MARC	物料的工厂数据	多以个工厂字段
MARD	物料的仓储位置数据   多一个库存地点
EKKO	采购订抬头数据	EKPO	采购订单项目
VBAK	销售订单抬头数据	VBAP	销售订单明细表
```



### 代码学习

#### 定义  关键字：

```abap
DATA	
类型：TYPE C  
char类型 
lenght 长度 
```

>  自定义表：ZPERSON_ZHOUXH



循环

```abap
LOOP AT <内标> INTO <工作区>.

ENDLOOP. 
执行次数循环
DO 10 TIMES.

ENDDO.
条件循环语句：对比符合也可以用英文 LE (<=) LT(<) GT(大于)  GE（>=） EQ(=)  NE(!=)
WHILE <条件>.
ENDWHILE.
*更新工作区内容到内标
modify IT_TABLE FROM wa_table INDEX sy-tabix.
```

##### 内表排序-去重的方法

```abap
内表排序:  不加参数是所有字段升序排序  默认 ASCENDING  可以不写   降序 DESCENDING
SORT <内标名> BY I<需要排序的字段-可以多个字段> DESCENDING.
例子：SORT IT_TABLE BY ID DESCENDING.
去重的方法: 需要先排序
删除相邻的重复内容 从 <内表名> 对比的字段是<id>
delete ADJACENT DUPLICATES FROM <IT_TABLE> COMPARING id.
```



##### 查询<字段> 到内表 从数据表里面

```abap
SELECT ZID ZNAME ZPHONE ZADDRESS
  INTO  CORRESPONDING FIELDS OF  TABLE IT_TABLE
   FROM ZPERSON_ZHOUXH.
```

##### 读取内表

```abap
READ TABLE it_table INTO wa_table WITH KEY name='<值>'.
* SY-SUBRC 代表成功
IF SY-SUBRC = 0.
ENDIF.
```



##### 设置显示语言：

```abap
 cl_demo_output=>display( IT_TABLE ).
```

##### 字段中间不需要，表别名的写法

```abap
SELECT a~ZID  a~ZNAME a~ZPHONE a~ZADDRESS a~ZQUANTITY  
  INTO  CORRESPONDING FIELDS OF  TABLE IT_TABLE   
  FROM ZPERSON_ZHOUXH as a.
```

> `CORRESPONDING FIELDS OF`   相匹配的字段

##### 取整

```abap
ceil  (向上取整) 
floor(向下取整)
trunc(取小数点前面的数)
frac (取小数点后面的数)
```

##### 求商

```abap
div(求商)
```

##### 求余数

```abap
 mod(求余数) 
```



清空表

```abap
clear:  <内表>.   //如果带表头需要清空2次。
free: it_makt.		//清空内表释放内存
refresh: it_makt.
```

更新

```abap
UPDATE <DB_TABLE>  FROM  <IT_TABLE>.
UPDATE <DB_TABLE> SET field1 = ...
		           field2 = ...
		where key1 = ...
		           key2 = ... .	
```

新增数据

```abap
INSERT <DB_TABLE> FROM <IT_TABLE>.
```

删除

```abap
DELETE <DB_TABLE> FROM <IT_TABLE>.
```

更新新增

```abap
MODIFY <DB_TABLE> FROM <IT_TABLE>.
//SAP隐式提交 一般不用写
异步更新
COMMIT WORK.
同步更新
COMMIT WOR AND WAIT.
```









#### 

#### 输出展示

cl_demo_output=>display( IT_TABLE ).

## 函数

函数模块=功能模块

加前导0函数

```abap
CONVERSION_EXIT_ALPHA_INPUT
新建---设置导入参数---带出参数----源代码
捕获异常
  TRY .
  CATCH CX_ROOT .
    RAISE <定义的例外>.
  ENDTRY.


EServer 
```



mdg 查表

```abap
TCODE：SE38  
USMD_DATA_MODEL   ->执行  
数据类型输入MM  ->执行

程序 MV45AFZZ  -> 源代码  显示    全局增强

二代增强
TCODE：cmod 查找增强程序      smod  查找增强组件
```



6.ALV函数

```abap
REUSE_ALV_GRID_DISPLAY
REUSE_ALV_GRID_DISPLAY_LVC
```

> 报表创建

se38->程序名->标题->类型->可执行程序->保存->本地对象



### 命名规范

内表	it_
工作群	wa_
导入参数命名  IV（inmport value）



## 事务代码

[云文档链接](http://note.youdao.com/groupshare/?token=97405BF35003424CB48ECE41CF9565BD&gid=101839388)

#### 资金计划查询

SE16N 查表ZTFI008_ZJJH
资金计划审批状态表 ZTFI050

SPROXY   接口查询事务码

推送类目
SE38  程序输入    ZRMDG＊　　　　查找　　ZRMDG003　　　选择后　　　F８执行

#### 数据推送

##### DRFOUT - 执行数据复制

- **物料主数据**

```ABAP
复制模型    ZMM_OUT
外向实施    194_1
```

- **客户主数据**

```ABAP
复制模型	ZBP_OUT
外向实施	ZBP_OI
```

#### ZRMDG003 - 推送类目

```abap
事务码：SE38  
程序输入：ZRMDG*
查找　　ZRMDG003
选择后　　　F８执行
```



### 采购入库

#### ME31N - 创建采购订单

- **Z001 标准采购订单**
- 确认 --> 确认控制：**0004 内向交货单**

#### ME29N - 批准采购订单

#### VL31N - 创建入库交货

- 运输：交货数量
- 抬头明细：装运条件 - **04**

### VL32N - 更改入库交货

### ME23N - 显示采购订单

### ME2L - 采购订单（按供应商）

### VL32N - 更改入库交货

### MB51- 物料凭证清单

### MB52 - 现有仓库库存清单

### ZSD028 - 外向交货单同步WMS

### ZMM025 - M301移动类型物料凭证生成会记凭证

### VL02N - 更改出库交货

### VL03N - 显示出库交货

### MMO1 - 创建物料

### MMO3 - 显示物料

### MIGO - 货物移动

## 功能

### SE16N - 数据表

- 内向交货：**LIKP** 
- 采购订单：**EKKO** 
- 内向交货 + 采购订单：**LIPS**
- 资金计划查询：**ZTFI008_ZJJH**
- 资金计划审批状态表：**ZTFI050**



### SE80 -函数组事务代码

```abap
创建函数组  ZFG_ZXH
输入框里ENTER 然后新建，描述写了后保存本地对象，然后激活
```



## 人力

### PA30 - 人力资源表事务码 

SE93-新增事务代码

```ABAP
#参照ZMAINT_ZHOUXH
事务  SM30  ->勾选跳过初始屏幕   GUI支持全选
屏幕字段名称    
VIEWNAME   ZPERSON_ZHOUXH    
UPDATE    X  （如果是显示 就SHOW）
保存  本地包
```





sm59 RFC链接事务码
