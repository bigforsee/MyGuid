# OA开发培训

## 一 目的

**无源码**

**无源码**

**无源码**

传递经验，共同进步





## 二 框架

![image-20220906154100990](C:\Users\周先海\OneDrive\文档\学习文档\泛微OA\三宁OA培训\images\image-20220906154100990.png)

## 三 Ecology 安装目录说明

- ecology：OA主程序目录 
- JDK：Java目录 
- Resin：应用服务器的目录

### ecology 

```
classbean 存放编译后的CLASS文件 
   js 系统中使用的JAVASCRIPT和VBSCRIPT脚本 
   css 系统中JSP页面使用的样式 
   images 
   images_face 
   images_frame 系统中使用的图片的存放目录 
   log 系统中日志存放目录 
   sqlupgrade升级SQL脚本目录 
   workflow 各功能分文件夹存放每个功能的文件 
   WEB-INF 
      lib 系统依赖Jar文件目录 
      prop 系统配置文件存放 
      service 系统的接口配置文件的存放 
      securitylog 安全补丁日志 
      securityXML自定义安全补丁配置目录
   	  service 系统的接口配置文件的存放 
      securitylog 安全补丁日志 
      securityXML自定义安全补丁配置目录

```



   

### resin 4.0.58

```
	bin 启动命令
​	conf 配置项
​	log 启动日志目录
​	logs 工作日志目录
```



### jdk

​	java8

### 常用表

#### 1.流程表

常用流程相关存储说明，详情见表结构说明文档，以下说明以自定义表单为例，自定义表单 `isbill=1`，数据库存储的表名为 `id<0` 对应表名为  `formtable_main_(id*-1)`，`id>0` 为固定表名，参见 `workflow_bill.tablename`

| **数据库表名**           | **中文说明**     | **备注**                       |
| ------------------------ | ---------------- | ------------------------------ |
| workflow_base            | 流程基本信息     | isbill=1                       |
| workflow_bill            | 流程表单信息     | id > 0固定表名 id < 0 动态生成 |
| workflow_billfield       | 表单字段信息     |                                |
| workflow_billdetailtable | 表单明细表       |                                |
| workflow_nodebase        | 节点信息         |                                |
| workflow_flownode        | 流程节点信息     |                                |
| workflow_nodelink        | 流程出口信息     |                                |
| workflow_nodegroup       | 节点操作人信息   |                                |
| workflow_groupdetail     | 节点操作人详情   |                                |
| workflow_requestbase     | 请求基本信息     |                                |
| workflow_currentoperator | 请求节点操作人   |                                |
| workflow_requestlog      | 请求签字意见     |                                |
| workflow_nownode         | 请求当前节点     |                                |
| workflow_browserurl      | 系统浏览按钮信息 |                                |
| workflow_selectitem      | 下拉框信息       |                                |

#### 2.人力资源相关数据存储

以下只列举一些常用表结构，更多表结构参考表建构文档。

| **表名**             | **说明**                     | **备注** |
| -------------------- | ---------------------------- | -------- |
| HrmResource          | 人力资源基本信息表           | -        |
| HrmResource_online   | 人员在线信息表               | -        |
| HrmResourceManager   | 系统管理员信息表             | -        |
| HrmDepartment        | 人力资源部门表               | -        |
| HrmDepartmentDefined | 人力资源部门自定义字段信息表 | -        |
| HrmSubCompany        | 人力资源分部表               | -        |
| hrmroles             | 角色信息表                   | -        |
| hrmrolemembers       | 角色人员                     | -        |
| hrmjobtitles         | 岗位信息表                   | -        |



#### 3.文档相关相关数据存储

以下只列举一些常用表结构，更多表结构参考表建构文档。

| **表名**       | **说明**                 | **备注** |
| -------------- | ------------------------ | -------- |
| Docdetail      | 文档信息表               | -        |
| DocDetailLog   | 文档操作日志表           | -        |
| DocImageFile   | 文档附件图片表           | -        |
| ImageFile      | 文件存放信息表           | -        |
| shareinnerdoc  | 文档共享表(针对内部人员) | -        |
| DocShare       | 文档共享信息表           | -        |
| DocShareDetail | 文档共享信息详细表       | -        |
| DocSecCategory | 文档子目录表             | -        |



## 三 前端



### Js基础配置

Ecology中需要使用到JS脚本的大部分是在流程中，流程模块使用JS通过流程表单编辑器的“插入代码块”实现，常用方式有两种：

①直接在代码块编辑框中输入JS代码

②单独写一个JS文件，在代码块编辑器中引用该文件（推荐，较大的优点是调试方便）

```
<script type="text/javascript" src= "/test/a.js" >
```





#### Js脚本开发注意要点

  ① js修改过代码后，会有缓存,上线后可以去除随机数

```
var js = "<script type='text/javascript' src='/kangmindong/js/kwah_01.js?v"+Math.random()+"'></"+"script>";
document.write(js);
```

② 编码格式

   在ecology9中所有的文件（例如JS、JSP、Java、CSS等）的编码格式都必须是UTF-8

③ 尽量不动原生的JS，因为有些原生代码会出现浏览器不兼容的问题



#### Js开发说明

- 流程表单中的字段ID是以“feild”开头

例如主表字段feild8391，如果是明细行字段，则为feild6271_0, feild6271_1,其中_0、_1表示明细行行标，明细行标从0开始

- 表单中隐藏字段indexnum0表示下一次明细行行标，每当点击明细的“新增”按钮时，则该字段的值自动加1，如果是第二个明细，则indexnum1，依次类推

- 表单中隐藏字段nodeid表示当前节点ID；requestid表示当前流程唯一标识ID，若流程未-1，表示该流程还未创建；needcheck表示必填字段，有多个字段必填，中间用逗号隔开，例如“feild9821,feild2619”



#### 开发应用

1. **获取表单数据：**

   jQuery(‘#field4001’).val

2. **赋值文本框、下拉框数据：**

   jQuery(“#field4001”).val('实际的值');

3. **赋值日期、浏览按钮：**

   jQuery(“#field4001”).val('数字');

   jQuery(“#field4001”).html('中文');

4. **Ajax**

   是指一种创建交互式网页应用的网页开发技术

   ```html
   jQuery.ajax({
            type:"POST",//要求为String类型的参数，请求方式（post或get）默认为get
            url: "/westvalley/workflowServlet.jsp?cmd=getHrToBumryyd",
            //要求为String类型的参数，（默认为当前页地址）发送请求的地址。
            data: 'jiablx='+this.value,//要求为Object或String类型的参数，
   发送到服务器的数据。get请求中将附加在url后。
            dataType:"text",//要求为String类型的参数，预期服务器返回的数据类型。
   如果不指定，可用的类型如下：
            json：返回JSON数据。
            text：返回纯文本字符串。
            success: function(data){
               	 $("#fieldXXXX").val(data.message);
            }
   });
   
   ```

   

   ```html
   <script type="text/javascript">
   	$(document).ready(function(){
   		$.ajax({
   	        type: "POST",
   	        url: "/userDefined/java/getTime.jsp",
   	        data: null,
   	        contentType: "application/json",
   	        success: function (result) {
   	            alert('ok');
   	        },
   	        error: function (error) {
   	            alert('error');
   	        }
   	    })
       })
   </script>
   ```

   后端请求实现

   ```html
   <%@ page language="java" contentType="text/html; charset=UTF-8" %>
   <%@ page import="weaver.general.*" %>
   <%@ page import="java.sql.*" %>
   <%@ page import="weaver.conn.RecordSet" %>
   <%@ page import="weaver.conn.RecordSetDataSource" %>
   
   if("getHrToBumryyd".equals(cmd)){//获取中台数据
   	try {
   		String jiablx = Util.null2String(request.getParameter("jiablx"));//日期
   		String msg = "对的";
   		String jsonJbsc = "{msg:'"+jiablx+"'}";
   		response.setContentType("text/html;charset=UTF-8");
   		response.getWriter().print(jsonJbsc.toString());
   	} catch (Exception e) {
   		e.printStackTrace();
   		log("获取数据异常："+e);
   	}
   
   }
   
   
   ```

   

### [e9 提供了封装的API](https://e-cloudstore.com/doc.html?appId=98cb7a20fae34aa3a7e3a3381dd8764e) 

​	

#### 1.注册自定义事件

保存、提交、退回、强制收回等等

```html
jQuery().ready(function(){
    WfForm.registerCheckEvent(WfForm.OPER_SAVE","+WfForm.OPER_SUBMIT","+WfForm.OPER_REJECTb function(callback){
       alert("拦截成功!");
       //callback();    //继续提交需调用callback，不调用代表阻断
    });
});
```



#### 2.表单字段的基础操作

##### a 、获取修改表单字段的值

| 参数      | 参数类型 | 必须 | 说明                                                 |
| --------- | -------- | ---- | ---------------------------------------------------- |
| fieldname | String   | 是   | 字段名称                                             |
| symbol    | String   | 否   | 表单标示，主表(main)/具体明细表(detail_1),默认为main |
| prefix    | Boolean  | 否   | 返回值是否需要`field`字符串前缀，默认为true          |

```html
var fieldid = WfForm.convertFieldNameToId("zs");//获取字段zs转换为fieldid
var fieldid = WfForm.convertFieldNameToId("zs_mx", "detail_1");//获取明细表1字段zs_mx转换为fieldid
var fieldid = WfForm.convertFieldNameToId("zs_mx", "detail_1", false);//获取明细表1字段zs_mx转换为数字id
var fieldvalue = WfForm.getFieldValue("field110");//获取字段field110的内容
```

##### b 、 获取改变字段的显示属性

| 参数      | 参数类型 | 必须 | 说明                                                         |
| --------- | -------- | ---- | ------------------------------------------------------------ |
| fieldMark | String   | 是   | 字段标示，格式`field${字段ID}_${明细行号}`                   |
| viewAttr  | int      | 是   | 改变字段的状态，1：只读，2：可编辑，3：必填，4：隐藏字段标签及内容，5:隐藏字段所在行(行内单元格不要存在行合并) |

```html
WfForm.changeFieldAttr("field110", 1);  //字段修改为只读
```



##### c 、 表单字段值变化触发事件

| 参数         | 参数类型 | 必须 | 说明                                                         |
| ------------ | -------- | ---- | ------------------------------------------------------------ |
| fieldMarkStr | String   | 是   | 绑定字段标示，可多个拼接逗号隔开，例如：field110(主字段),field111_2(明细字段)…… |
| funobj       | Function | 是   | 字段值变化触发的自定义函数，函数默认传递以下三个参数，参数1：触发字段的DOM对象，参数2：触发字段的标示(field27555等)，参数3：修改后的值 |

```html
WfForm.bindFieldChangeEvent("field27555,field27556", function(obj,id,value){
    console.log("WfForm.bindFieldChangeEvent--",obj,id,value);
});
```







## 四 . 后端

#### 1.流程节点事件action

- **节点附加操作的执行顺序**

保存表单数据-->节点后附加操作-->生成编号-->出口附加规则-->节点前附加操作-->插入操作者和签字意见

注：流程存为文档（workflowToDoc）接口特殊处理，作为流程提交的最后一个action执行



- **流程表单 action 的存放目录**

src/com/customization/action



- #### **流程表单action能做什么**

##### 1.获取流程相关信息

requestid、workflowid、formid、isbill、表单信息等

```java
 		WSUtil wsUtil = new WSUtil();
        //封装流程表单的值
        ActionUtil actionUtil = new ActionUtil();
        Map<String, Object> requestMap = actionUtil.initRequestData(request);
        mainMap = (HashMap<String, String>) requestMap.get("mainMap");
        detailMap = (HashMap<String, HashMap<String, HashMap<String, String>>>) requestMap.get("detailMap");
        //所有明细表的值
        wsBaseInfo = (WSBaseInfo) requestMap.get("wsBaseInfo");
        requestid = request.getRequestid();
        formid = "" + request.getRequestManager().getFormid();
        wf_creater = (int) requestMap.get("wf_creater");
        wf_formid = (int) requestMap.get("wf_formid");
        wf_isbill = (int) requestMap.get("wf_isbill");
        String requestid = request.getRequestid();
        RequestManager rm = request.getRequestManager();
```



##### 2.执行sql语句

查询或更新OA系统中的数据；

```java
   RecordSet recordSet = new RecordSet();
   String updatesql = "update formtable_main_" + wsBaseInfo.getFormid() + " set wlpz='" + arg2 + "' where requestid='" + rm.getRequestid() + "'";
  if (this.getYdlx().equals("315")) {
        updatesql = "update formtable_main_" + wsBaseInfo.getFormid() + " set drwlpz='" + arg2 + "' where requestid='" + rm.getRequestid() + "'";
       }
    recordSet.execute(updatesql);
```

带事务执行SQL开始

```java
 /*************2.带事务执行SQL开始***************/
        RecordSetTrans rst = new RecordSetTrans();
        rst.setAutoCommit(false);
        try {
            rst.executeUpdate("update formtable_main_45 set testFieldName1 = ? where requestid = ?", "testValue1", requestid);
            rst.executeUpdate("update formtable_main_45 set testFieldName2 = ? where requestid = ?", "testValue2", requestid);
            //手动提交事务
            rst.commit();
        } catch (Exception e) {
            //执行失败，回滚数据
            rst.rollback();
            e.printStackTrace();
        }
 /*************2.带事务执行SQL结束***************/
```



##### 3.返回失败标识和提示信息

阻断前台流程提交，并显示提示信息；

```java
                    request.getRequestManager().setMessageid("90002");
                    request.getRequestManager().setMessagecontent("请求ID:" + rm.getRequestid() + "; <br/><font style=\"color:#6e6e6e;font-size: 12px; font-weight: 700;\">数据发送给SAP处理时返回错误!请联系关键用户处理。</br>SAP返回的参考信息如下:</font><br/>" + result);
                    WSUtil.sendSapErrorInfo(requestid, xml, result);
                    return Action.FAILURE_AND_CONTINUE;
```



##### 4.调用第三方系统的接口

```java
   //往SAP传值
                String result = new WSDLUtil().SapPostByBasic(url, xml, request);

  //okhttp3
            OkHttpClient client = new OkHttpClient().newBuilder()
                    .build();
            Request request = new Request.Builder()
                    .url(url)
                    .method("GET", null)
                    .addHeader("Authorization", "Basic UUlOR0w6cWdsMTIz")
                    .addHeader("Cookie", "sap-contextid=SID%3aANON%3aBWPRDAPP01_BWP_00%3asq1-s7qEhZyDB6YfmgNXuX_03Jd61EuTt9VZ2xjy-NEW; sap-usercontext=sap-client=800; SAP_SESSIONID_BWP_800=AYfb9df10h6yRnLszBRXS2IVGp_pDRHrteMAUFa1Xyw%3d")
                    .build();
            Response response = client.newCall(request).execute();
            SAXReader reader = new SAXReader();
            document = reader.read(response.body().byteStream());
            Element root = document.getRootElement();
            List<Element> elements = document.selectNodes("//m:properties");
```



#### 2.如何编写一个action

- **编写一个 `JAVA` 类，要先实现 `weaver/interfaces/workflow/action/Action.java` 接口**

```java
public class MM330_SC_1060_MM_MaterialDoc implements Action 
```



- 参数的使用

![image-20220906172844473](C:\Users\周先海\OneDrive\文档\学习文档\泛微OA\三宁OA培训\images\image-20220906172844473.png)

```java
public String type = "2";

public String getType() {
    return type;
}

public void setType(String type) {
    this.type = type;
}
public class WfFormAction implements Action {

        new BaseBean().writeLog("接收的参数str:"+str);
        /**********执行action的业务逻辑************/
        new BaseBean().writeLog("我是action,我正在执行");

        return Action.SUCCESS;
}
```





#### 3. 怎么发布一个定时任务

![image-20220906173244959](C:\Users\周先海\OneDrive\文档\学习文档\泛微OA\三宁OA培训\images\image-20220906173244959.png)



**编写计划任务必须继承 `weaver.interfaces.schedule.BaseCronJob ` 类,重写方法 `public void execute() {}` **

```java
package com.customization.cronjob;
import weaver.general.BaseBean;
import weaver.interfaces.schedule.BaseCronJob;
public class jobTest extends BaseCronJob {
    @Override
    public void execute() {
        BaseBean baseBean = new BaseBean();
        baseBean.writeLog("=============conlog jobTest log========");
    }
}
```



#### 4.怎么写API接口并发布

必须放在 `src/com/api/customization` 目录下面

```java
package com.api.customization;

import com.customization.api.alibabapricecomparisonlist.web.alibabaPriceComparisonListAction;

import javax.ws.rs.Path;

@Path("/ali1688")
public class AlibabaApi extends alibabaPriceComparisonListAction {
}
```

然后在 `com/customization/api`  下实现方法

```java
alibabaPriceComparisonListAction
    
    @GET
    @Path("/test")
    @Produces(MediaType.TEXT_PLAIN)
    public String test(@Context HttpServletRequest request, @Context HttpServletResponse response) {
        Map<String, Object> res = new HashMap<>();
        res.put("msg", "Hello My World");
        return com.alibaba.fastjson.JSONObject.toJSONString(res);
    }
```



如果需要免登录访问，需要配置白名单。路径：/ecology/WEB-INF/prop/weaver_session_filter.properties。修改完，重启服务



#### 5.怎么写WebService并发布

先写一个接口在 `src/com/customization/webservices` 目录 

```java
public interface MyWebservices {
    String sayHello(String param);
}
```

在写一个实现类

```java
public class MyWebservicesImpl implements MyWebservices {
    @Override
    public String sayHello(String param) {
        //实现自己的逻辑
        return "Hello world: "+param;
    }
}
```





然后在文件内加入 `classbean\META-INF\xfire\services.xml` 内容

```xml
    <service>
        <name>MyWebservices</name>
        <namespace>http://webservices.cux.weaver.com.cn</namespace>
        <serviceClass>com.customization.webservices.workflow.testwebservices.MyWebservices</serviceClass>
        <implementationClass>com.customization.webservices.workflow.testwebservices.MyWebservicesImpl</implementationClass>
    </service>
```



#### 6.日志

##### a.systemout

idea调试打印

```java
#日志输出设置，默认为basebean，打印到ecology中，也可设置为systemout，可用于idea中调试，
```

##### b.ecology打印

```java
 BaseBean baseBean = new BaseBean();
        baseBean.writeLog("=============conlole jobTest log ========");
```

##### c.自定义打印

```shell
ecology/WEB-INF/prop/sapXIsoap.properties

```

开启自定义打印 `isDevlog=1` 

```java
 new ActionUtil().writeLogNew("输出你想输出的内容!");
```



#### 7 . 怎么获取异构数据源

```hava
    @GET
    @Path("/getDataSource")
    @Produces({MediaType.APPLICATION_JSON})
    public String testDataSource(@Context HttpServletRequest request, @Context HttpServletResponse response){
        Map<String, Object> apidatas = new HashMap<>();
        RecordSetDataSource rsd = new RecordSetDataSource("sync_gzszf");
        String sql = " select count(1) as num from hrmresource";
        rsd.execute(sql);
        if(rsd.next()){
            String num = rsd.getString("num");
            apidatas.put("num",num);
        }
        return JSONObject.toJSONString(apidatas);
    }
```



#### 8 . **获取系统配置文件方法**

```java
    @GET
    @Path("/getPropValue")
    @Produces({MediaType.APPLICATION_JSON})
    public String getPropValue(@Context HttpServletRequest request, @Context HttpServletResponse response){
        Map<String, Object> apidatas = new HashMap<>();
        BaseBean baseBean = new BaseBean();
        String propValue = baseBean.getPropValue("testProp", "sms");
        apidatas.put("prop",propValue);
        return JSONObject.toJSONString(apidatas);
    }
```



#### `executeBatchSql  `**使用方法**

```java
RecordSet rs = new Recordset();
List<List> pramArr = new ArrayList<>();
pramArr.add(new ArrayList<>(Arrays.asList("cG01-20210104-1001","168268")));
pramArr.add(new ArrayList<>(Arrays.asList("c601-20210104-1021","168277")));
boolean b = rs.executeBatchSql( s: "insert into formtable_main_271(dh sqr) values(? ?)",pramArr);
log.writeLog( msg: "try executeBatchSql 【"+ b +"】");
```





#                                  **THANKS**