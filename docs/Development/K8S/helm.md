# Helm3安装

[官网地址](https://helm.sh/docs/intro/install/)

# 根据操作系统去获取最新二进制安装包

# https://github.com/helm/helm/releases       

wget https://get.helm.sh/helm-v3.3.1-linux-amd64.tar.gz       
# 由于helm包在国外,我通过ss拉到了腾讯云cos,国内可通过以下地址访问:https://download.osichina.net/tools/k8s/helm/helm-v3.3.1-linux-amd64.tar.gz       
tar -zxvf helm-v3.3.1-linux-amd64.tar.gz       
cp linux-amd64/helm /usr/local/bin/



### 重要概念

Helm 有三个重要概念：

- chart：包含了创建`Kubernetes`的一个应用实例的必要信息
- config：包含了应用发布配置信息
- release：是一个 chart 及其配置的一个运行实例



```shell
# helm-v2
# wget https://get.helm.sh/helm-v2.10.0-rc.1-linux-amd64.tar.gz
 
# helm-v3
# wget https://get.helm.sh/helm-v3.3.4-linux-amd64.tar.gz
 
# tart -zxvf helm-v3.3.4-linux-amd64.tar.gz
 
# mv linux-amd64/helm /usr/local/bin/helm
 
# helm version
version.BuildInfo{Version:"v3.3.4", GitCommit:"a61ce5633af99708171414353ed49547cf05013d", GitTreeState:"clean", GoVersion:"go1.14.9"}
```



卸载清除

```shell
helm delete --purge my-release
```

> 净化彻底清除



### Helm 创建 `jenkins`

```shell
 helm install my  my-repo/jenkins --set global.storageClass=managed-nfs-storage --set jenkinsPassword=user123 -n dev-ops
```

>  `managed-nfs-storage` 根据自己的 `storageClass` 修改
