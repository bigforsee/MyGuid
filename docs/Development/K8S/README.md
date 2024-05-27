#### 节点选择

先在Node打标签 如系统自带的 ：**kubernetes.io/hostname=dom01**

```yml
      nodeSelector:
        deploy.server: oa-test-server
```





####  亲和性

```yml
pod.spec.affinity.podAffinity
  requiredDuringSchedulingIgnoredDuringExecution  硬限制
    namespaces       指定参照pod的namespace
    topologyKey      指定调度作用域
    labelSelector    标签选择器
      matchExpressions  按节点标签列出的节点选择器要求列表(推荐)
        key    键
        values 值
        operator 关系符 支持In, NotIn, Exists, DoesNotExist.
      matchLabels    指多个matchExpressions映射的内容
  preferredDuringSchedulingIgnoredDuringExecution 软限制
    podAffinityTerm  选项
      namespaces      
      topologyKey
      labelSelector
        matchExpressions  
          key    键
          values 值
          operator
        matchLabels 
    weight 倾向权重，在范围1-100
    
topologyKey用于指定调度时作用域,例如:
    如果指定为kubernetes.io/hostname，那就是以Node节点为区分范围
	如果指定为beta.kubernetes.io/os,则以Node节点的操作系统类型来区分
```



#### 创建资源清单输出到文件

```shell
kubectl create deployment web --image=nginx -o yaml --dry-run > hello.yaml
```

`如果是追加到文件需要 >>`  多个资源文件分隔符  `---`

