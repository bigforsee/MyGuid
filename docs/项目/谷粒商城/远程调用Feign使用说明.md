# 远程调用的方法 Fengn

## 1.启动服务需要先注册 

```java
@EnableDiscoveryClient
```

## 2.添加注解扫描接口

`扫描当前包所在的位置`

```java
@EnableFeignClients(basePackages = "com.atguigu.gulimall.member.feign")
```

## 3.配置项需添加

```yml
spring:
  cloud:
    nacos:
      discovery:
        server-addr: 127.0.0.1:8848    #注册服务中心
        port: ${server.port}			#本服务端口
        ip: 127.0.0.1					#本机IP
```

## 4. Feign包注解需要说明去哪个服务

```java
@FeignClient("gulimall-coupon")
```

## 5.接口需要描述清楚完整路径

```java
  @RequestMapping("/coupon/coupon/member/list")//目标全地址
    R membercoupons();//目标方法名称
```

