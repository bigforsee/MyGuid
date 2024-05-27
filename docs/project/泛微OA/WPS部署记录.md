## OA地址

```html
https://testoa.hb30.com
```

#### WPS地址

```html
地址参考:https://10.30.29.81/open，
账号密码：wpsadmin/Wps@123456
授权审批：https://doc.hb30.com/openplatform
域名地址:https://doc.hb30.com
版本信息:release_wpsyun_v6.0.2206.20220628.97
```



### **证书回调地址**

```html
https://testoa.hb30.com/api/wps/doccenter/outter/licence/receive
```



### **编辑回调**

```html
https://testoa.hb30.com/api/wps/doccenter/outter
```



#### 获取文件元数据：

```
/v1/3rd/file/info
```

#### 获取用户信息：

```html
/v1/3rd/user/info
```

#### 上传文件新版本：

```html 
/v1/3rd/file/save
```

#### 获取指定版本信息：

```html
/v1/3rd/file/version/:version
```

#### 获取所有版本信息：

```html
/v1/3rd/file/history
```

#### 文件重命名：

```html
/v1/3rd/file/rename
```

#### 获取文件状态：

```html
/v1/3rd/file/online
```

#### 回调通知：

```html
/v1/3rd/onnotify
```

> 新版本的服务中新增了两个开关“是否编辑应用文档”、“是否开启编辑锁”，泛微服务中对接用不到，请勿打开。



### 预览回调

```html
https://testoa.hb30.com/api/wps/doccenter/outter
```

#### 获取文件元数据：

```html
/v1/3rd/file/info
```

#### 回调通知：

```html
/v1/3rd/file/view/notify
```



### 设置格式处理回调

#### 回调域名：

```html
https://testoa.hb30.com/api/wps/doccenter/outter
```

#### 处理结果通知：

```html
/v1/3rd/cps/callback
```



## OA配置文件修改

#### WPS相关配置

注册WPS得到doccenter_appid  doccenter_sercet 后改相关内容

```shell
/app/weaver/ecology/WEB-INF/prop/doc_wps_for_weaver.properties
```

```shell
doccenter_open=1
# V5版服务预览开关，不配置默认为1
doccenter_open_view=
# V5版服务编辑开关，不配置默认为1
doccenter_open_edit=
# V5版服务格式转换开关，不配置默认为1,一般与doccenter_open_view保持一致
doccenter_open_format=
# V5版服务地址服务地址
# 带http(s) 的完整地址，有端口要带端口（http的80 和 https的443忽略）
# 结尾不要带 / 不要有多余的空格，会导致签名失败
# 如果配置了webpath，要加上webpath
# 举例：
#    doccenter_domain=http://10.10.27.103
#    doccenter_domain=http://10.10.27.103:8081
#    doccenter_domain=http://10.10.27.103/wpsdocs
#    doccenter_domain=https://www.stonestudio.top
doccenter_domain=https://doc.hb30.com
# 应用appid (ak),请把参数替换成客户的。
# 【重要】不同的OA，请使用不同的appid，否则会产生数据混乱。同一套OA（集群），使用同一个appid即可。
doccenter_appid=SX20220722VJBINW
# 应用sercet (sk),请把参数替换成客户的。
# 【重要】不同的OA，请使用不同的sercet，否则会产生数据混乱。同一套OA（集群），请使用同一个sercet即可
doccenter_sercet=2122456f9b1aad90f2231e65684ce291

doccenter_wpsPreview=1110110

# 超管ak,用于定时任务检查授权到期时间，以提醒
doccenter_manage_appKey=
# 超管sk,用于定时任务检查授权到期时间，以提醒
doccenter_manage_sercetKey=

# 输出wps服务请求oa时的所有参数及请求头，仅供调试使用，日常请关闭
# 1、开启；0、关闭
doccenter_showAllRequestParameters=0

# 移动端是否默认转为pdf文件后再预览
# 1、转为pdf后再预览；0、维持直接预览word
doccenter_needConvertPdfForWord=

###### 此部分参数为预览时使用 ######
# 颜色及透明度
doccenter_water_viewer_fillstyle=rgba(192,192,192,0.6)
# 字体样式
doccenter_water_viewer_font=normal 24px kaiti
# 旋转角度
doccenter_water_viewer_rotate=
# 水印宽度
doccenter_water_viewer_width=80
# 水印高度
doccenter_water_viewer_height=160

###### 此部分参数为下载时使用 ######
# 水印内容为文字时的样式配置
# 文字大小
doccenter_water_text_size=25
# 文字颜色
doccenter_water_text_color=#DEDEDE
# 水印透明度
doccenter_water_text_transparent=0.4
# 位置枚举：TOP_LEFT | TOP_CENTER | TOP_RIGHT | CENTER_LEFT | CENTER | CENTER_RIGHT | BOTTOM_LEFT | BOTTOM_CENTER | BOTTOM_RIGHT
doccenter_water_text_position=CENTER
# 水印是否平铺
doccenter_water_text_tiled=true
# 水印字体，仅在文件是图片时生效
doccenter_water_text_font_name=Microsoft YaHei
# 是否加粗，仅在文件是图片时生效
doccenter_water_text_bold=true
# 是否倾斜，仅在文件是图片时生效
doccenter_water_text_italic=true
# 旋转角度，仅在文件是图片时生效
doccenter_water_text_rotate=0
# 是否倾斜45度，仅在文件是文档时生效
doccenter_water_text_tilt=true

# 水印内容是图片时的样式配置
# 位置枚举：TOP_LEFT | TOP_CENTER | TOP_RIGHT | CENTER_LEFT | CENTER | CENTER_RIGHT | BOTTOM_LEFT | BOTTOM_CENTER | BOTTOM_RIGHT
doccenter_water_image_position=CENTER
# 是否平铺
doccenter_water_image_tiled=true
# 水印图片缩放比例，取值范围0.1~5
doccenter_water_image_scale=1
# 是否取消冲蚀,仅在文件是文档时生效
doccenter_water_image_no_washout=false
# 是否倾斜45度,仅在文件是文档时生效
doccenter_water_image_tilt=true
# 透明度，仅在文件是图片时生效
doccenter_water_image_transparent=0.4
# 旋转角度，仅在文件是图片时生效
doccenter_water_image_rotate=
######此部分为特殊参数，一般客户不需要配置 ######
# 泛微生产环境开发，客户几乎用不到
# 对下载接口中返回的oss、obs地址做替换内网的处理
doccenter_replaceOssUrl4Inner=
# oss替换的内网地址
doccenter_ossInnerUrl=
# 区分是否是V5版服务调用的下载接口，根据user-agent判断，编辑场景。目前默认参数为：Apache-HttpClient
doccenter_wpsUA4View4Download=
# 区分是否是V5版服务调用的下载接口，根据user-agent判断，预览场景。目前默认参数为：Go-http-client
doccenter_wpsUA4Edit4Download=

```



#### WPS开关配置

```shell
/app/weaver/ecology/WEB-INF/prop/docpreview.properties
```

```shell
# 是否使用第三方预览服务
isUsePDFViewer=1
```

#### Setvlet配置

```
/app/weaver/ecology/WEB-INF/web.xml
```

确保存在

```xml
<servlet>
       <servlet-name>FileDownloadForWps</servlet-name>
        <servlet-class>weaver.file.other.DownloadForTokenServlet</servlet-class>
</servlet>
<servlet-mapping>
        <servlet-name>FileDownloadForWps</servlet-name>
        <url-pattern>/weaver/weaver.file.FileDownloadForWps</url-pattern>
</servlet-mapping>
```



## pdf走第三方转换 开启后EM的阅读全部走预览

修改配置文件不需要重启

```shell
ecology/WEB-INF/prop/doc_custom_for_weaver.properties
pdfConvert=1
```





