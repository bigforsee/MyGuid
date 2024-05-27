# OAuth2学习笔记

[oauth2 文档](https://pkg.go.dev/gopkg.in/oauth2.v3)

[https://github.com/go-oauth2/oauth2/blob/master/server/server.go](https://github.com/go-oauth2/oauth2)

## OAuth2的4重授权流程（grant_type）

- 授权码（authorization_code）
  - 用户登录授权，先拿code
  - 用code换token
- 隐含式（implicit）
  - 用户登录授权，不拿code，直接拿token
- 密码式(password)
  - *用户提前给客户端用户密码*（不是oauth2完成的）
  - 验证客户端，直接用用户名和密码拿token
- 客户端凭证（client_credentlials）
  - 验证客户端，直接拿token



### authorization_code

![image-20220127091459546](C:\Users\周先海\OneDrive\文档\学习文档\OAuthh2\images\image-20220127091459546.png)

1. 获取授权code

   ***参数说明***

   1. | 参数          | 类型    | 说明                                                 |
      | ------------- | ------- | ---------------------------------------------------- |
      | client_id     | String  | 在oauth2 server注册的client_id                       |
      | response_type | string  | 固定值 code                                          |
      | scope         | string  | 权限范围，`str1,str2,str3`，如果没有特殊说明填写 all |
      | state         | string  | 验证请求的标志字段                                   |
      | rediect_rui   | sttring | 发放`code`                                           |

   http://127.0.0.1:3000/oauth/authorize?client_id=ruoyi&response_type=code&scope=server&state=a-LOGIN&rediect_rui=http://127.0.0.1:8089/sso/login

   http://127.0.0.1:3000/oauth/authorize?response_type=code&scope=server&client_id=ruoyi&state=null-LOGIN&redirect_uri=http://127.0.0.1:8089/sso/login

   

   http://localhost:8089/sso/login
   
   

   

   **2.使用`code` 交换`token`**

   `post` `/token`

   请求头 Authorization
   
   - basic auth
   - username:`client_id`
   - password:`client_cecret`

   **Herder**
   
   `Content-Type: application/-www-form-urlencoded`
   
   **Body 参数说明**
   
   | 参数         | 类型   | 说明                       |
   | ------------ | ------ | -------------------------- |
   | grant_type   | string | 固定值`authorization_code` |
   | code         | string | 发放的code                 |
   | redirect_uri | string | 前面填写的redirect_uri     |
   
   

### 其他3种

![image-20220127091633649](C:\Users\周先海\OneDrive\文档\学习文档\OAuthh2\images\image-20220127091633649.png)

#### 2.implicit

资源请求方(client方)使用,多用于没有后端的应用,用户授权登录后,会直接向前端发送令牌(access_token)

请求方式

`get` `/authorize`

**参数说明**

| 参数          | 类型   | 说明                                                         |
| ------------- | ------ | ------------------------------------------------------------ |
| client_id     | string | 在 oauth2 server 注册的client_id                             |
| response_type | string | 固定值`token`                                                |
| scope         | string | 权限范围,`str1,str2,str3`,没有要求就all                      |
| state         | string | 验证请求的标志字段                                           |
| redirect_uri  | string | 回调地址,会携带`token`,'scope',`state`,过期时间`expires_in`,token_type内容,没有access token |

**注意**

​	1.返回设置的state 在下一步之前验证,防止劫持和篡改

​	2.这种令牌直接给前端是不安全的,因此令牌有效期比较短,只能用于一些安全性不高的场景,通常是会话有效,浏览器关闭就失效了.

#### 3.password

资源请求方(client方)使用,如果充分新人接入应用(client),用户就可以把用户名密码给接入应用,接入应用通过用户名密码申请令牌

**请求方式**

`POST` `/token`

**请求头 Authorization**

- basic auth
- username:`client_id`
- password:`client_secret`

**Header**

`Content-Type: applicationg/x-www-form-urlencoded`

**Body参数说明**

| 参数       | 类型   | 说明                                            |
| ---------- | ------ | ----------------------------------------------- |
| grant_type | string | 固定值`password`                                |
| username   | string | 用户名                                          |
| password   | string | 用户密码                                        |
| scope      | string | 权限范围,`str1,str2,str3`,如果没有特殊要求就all |



#### 4.client_credentdials

资源使用方使用在oauth2服务器注册时的client_id和client_seret获取的access_token，发出的api请求时，他应将access_token作为bearer令牌传递到Authorization请求头中

**请求方式**

`POST` `/token`

**请求头**

- basic auth
- username:`client_id`
- password:`client_secret`

**Header**

`Content-Type: application/x-www-form-urlencoded`

Body参数说明

| 参数       | 类型   | 说明                                            |
| ---------- | ------ | ----------------------------------------------- |
| grant_type | string | 固定值`client_credentials`                      |
| scopr      | string | 权限范围,`str1,str2,str3`,如果没有特殊要求就all |

### 验证token

​	**接口说明**

​	这个接口是资源端使用的，用来验证`access_token` `scope` 和`domain`.



