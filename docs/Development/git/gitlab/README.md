# 需要先按照NFS服务

```yaml
nfs:
    server: 192.168.1.100  #这个就是nfs服务端的机器ip，也就是k8s的master1节点ip
    path: /mnt/data

```

这个是NFS服务器的IP和挂载目录

## 注意 `namespaces`

我这里用的 `dev-ops` 根据自己的修改

[文档地址](https://blog.csdn.net/weixin_38320674/article/details/106821838)