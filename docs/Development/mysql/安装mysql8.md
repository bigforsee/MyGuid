## 安装mysql8

### 1.下载MySQL安装脚本

```shell
wget  http://dl.qiyuesuo.com/private/mysql/mysqlinstall.sh
```

### 2.执行脚本（5.7使用1，8.0使用2）

```shell
/bin/bash mysqlinstall.sh 2
```

### 3.输入自定义MySQL安装路径，默认为/mysql， 如果指定的目录不存在则自动创建(最好由脚本自动创建或者保证指定的目录为一个空目录)

```shell
/mysql
```

### 4.指定root用户密码，至少8位，至少包含大小写字母、数字、特殊字符中的三者（否则之后重启数据库会提示密码错误无法登录） 如果出现此问题请参考知识树[修改密码]()

```shell
Root@123
```

### 5.安装成功 ，请根据服务器磁盘类型优化/etc/my.cnf文件末尾的innodb_io_capacity和innodb_io_capacity_max参数

```config
# innodb_io_capacity_max一般设置为innodb_io_capacity的2倍，对于SSD硬盘，innodb_io_capacity可以设置8000更高甚至上万的值，对于普通SAS硬盘，可设置200，对于sas raid10可设置2000，对于fusion-io闪存设备可设置几万以上，注意：此参数对于数据库性能影响很大，根据实际磁盘类型进行调整。
```

### 6.改完参数后重启数据库服务，至此安装结束

```shell
systemctl restart mysqld
```

### 7.改完参数后重启数据库服务，至此安装结束

```mysql
mysql -uroot -pRoot@123
create user 'root'@'10.30.94.45' identified by 'Root@123';
grant all privileges on *.* to 'root'@'10.30.94.45' with grant option;
flush privileges;
```

create user 'root'@'10.30.30.112' identified by 'Root@123';



## 包安装MYSQL8.0

```shell
wget https://www.gitlink.org.cn/attachments/entries/get_file?download_url=https://www.gitlink.org.cn/api/lengleng/mirror/raw/mysql80-community-release-el7-11.noarch.rpm?ref=master -O mysql80-community-release-el7-7.noarch.rpm

rpm -ivh mysql80-community-release-el7-7.noarch.rpm

yum install -y mysql mysql-server

# 修改配置文件
vim /etc/my.cnf
lower_case_table_names=1

# 重启mysql
systemctl restart mysqld

# 查看默认密码 (注意复制全了很多特殊字符)
grep password /var/log/mysqld.log

# mysql client 链接 mysql
mysql -uroot -p

# 修改默认密码为 root
alter user 'root'@'localhost' identified by 'ZxcRoot123!@#';
set global validate_password.check_user_name=0;
set global validate_password.policy=0;
set global validate_password.length=1;
alter user 'root'@'localhost' identified by 'root';

# 修改为允许远程访问
use mysql;
update user set host = '%' where user = 'root';
FLUSH PRIVILEGES;
```

三宁K8S 上安装 MYSQL5.7  
vi `mysql-deploy.sh` 插入下面内容
```shell
#!/bin/bash
#本程序适用与三宁在 K8S上 创建 MYSQL 部署
# MySQL K8S 部署管理脚本 - 高阶版本
# 用法: 
#   创建: ./mysql-deploy.sh create <namespace> <app-name>
#   删除: ./mysql-deploy.sh delete <namespace> <app-name>

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置变量
SCRIPT_NAME=$(basename "$0")
MYSQL_YAML="mysql.yaml"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 打印颜色信息
print_color() {
    local color=$1
    local level=$2
    local message=$3
    echo -e "${color}[${level}]${NC} ${message}"
}

print_info() {
    print_color "$GREEN" "INFO" "$1"
}

print_warning() {
    print_color "$YELLOW" "WARNING" "$1"
}

print_error() {
    print_color "$RED" "ERROR" "$1"
}

print_debug() {
    print_color "$BLUE" "DEBUG" "$1"
}

print_success() {
    print_color "$CYAN" "SUCCESS" "$1"
}

# 显示用法
usage() {
    echo -e "${CYAN}MySQL K8S 部署管理脚本 - 高阶版本${NC}"
    echo ""
    echo -e "${GREEN}用法:${NC}"
    echo -e "  ${SCRIPT_NAME} create <namespace> <app-name>    ${YELLOW}# 创建 MySQL 部署${NC}"
    echo -e "  ${SCRIPT_NAME} delete <namespace> <app-name>    ${YELLOW}# 删除 MySQL 部署${NC}"
    echo ""
    echo -e "${GREEN}示例:${NC}"
    echo -e "  ${SCRIPT_NAME} create sn-wms-test wms          ${YELLOW}# 在 sn-wms-test 命名空间创建 mysql-wms${NC}"
    echo -e "  ${SCRIPT_NAME} delete sn-wms-test wms          ${YELLOW}# 删除部署${NC}"
    echo ""
    echo -e "${GREEN}说明:${NC}"
    echo -e "  <namespace>  : Kubernetes 命名空间"
    echo -e "  <app-name>   : 应用名称（会生成 mysql-<app-name> 的资源）"
    echo ""
    exit 1
}

# 检查参数数量
check_argument_count() {
    local expected=$1
    local actual=$2
    local operation=$3
    
    if [ "$actual" -lt "$expected" ]; then
        print_error "${operation} 操作需要 ${expected} 个参数，但提供了 ${actual} 个"
        echo ""
        usage
    fi
}

# 检查参数是否为空
check_argument_empty() {
    local arg_value=$1
    local arg_name=$2
    local operation=$3
    
    if [ -z "$arg_value" ]; then
        print_error "${operation} 操作中参数 ${arg_name} 不能为空"
        echo ""
        usage
    fi
}

# 验证参数格式
validate_arguments() {
    local namespace=$1
    local app_name=$2
    local operation=$3
    
    # 检查命名空间格式（K8S命名空间命名规则）
    if ! echo "$namespace" | grep -qE '^[a-z0-9]([-a-z0-9]*[a-z0-9])?$'; then
        print_error "命名空间格式无效: $namespace"
        print_error "命名空间必须符合K8S命名规范：小写字母、数字、连字符，且不能以连字符开头或结尾"
        exit 1
    fi
    
    # 检查应用名称格式
    if ! echo "$app_name" | grep -qE '^[a-z]([-a-z0-9]*[a-z0-9])?$'; then
        print_error "应用名称格式无效: $app_name"
        print_error "应用名称必须以小写字母开头，只能包含小写字母、数字和连字符"
        exit 1
    fi
    
    # 检查应用名称长度
    if [ ${#app_name} -gt 20 ]; then
        print_error "应用名称过长: $app_name (最大20个字符)"
        exit 1
    fi
}

# 检查必要的命令
check_commands() {
    local missing_commands=()
    
    if ! command -v kubectl &> /dev/null; then
        missing_commands+=("kubectl")
    fi
    
    if [ ${#missing_commands[@]} -gt 0 ]; then
        print_error "缺少必要的命令: ${missing_commands[*]}"
        print_info "请确保这些命令已安装并配置正确"
        exit 1
    fi
    
    # 检查 kubectl 是否能够连接集群
    if ! kubectl cluster-info &> /dev/null; then
        print_warning "无法连接到 Kubernetes 集群，请检查 kubectl 配置"
        print_info "尝试运行: kubectl cluster-info"
    fi
}

# 生成动态的 mysql.yaml 文件
generate_mysql_yaml() {
    local namespace=$1
    local app_name=$2
    
    print_debug "生成动态 MySQL YAML 配置文件..."
    
    cat > "$MYSQL_YAML" << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: $namespace
  name: mysql-$app_name
  labels: {}
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: eds-nas-v5
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: mysql-config-$app_name
  namespace: $namespace
  annotations:
    kubesphere.io/creator: admin
data:
  mysql-config.cnf: |
    [mysqld]
    skip-host-cache
    skip-name-resolve
    datadir=/var/lib/mysql
    socket=/var/run/mysqld/mysqld.sock
    secure-file-priv=/var/lib/mysql-files
    user=mysql
    lower_case_table_names=1
    symbolic-links=0
    pid-file=/var/run/mysqld/mysqld.pid

    [client]
    socket=/var/run/mysqld/mysqld.sock

    !includedir /etc/mysql/conf.d/
    !includedir /etc/mysql/mysql.conf.d/
---
kind: Secret
apiVersion: v1
metadata:
  name: mysql-$app_name
  namespace: $namespace
  labels:
    app: mysql-$app_name
    app.kubernetes.io/managed-by: Helm
  annotations:
    kubesphere.io/creator: admin
data:
  mysql-password: V21zQE15c3FsLmhiMzA==
  mysql-root-password: V21zQE15c3FsLmhiMzA==
type: Opaque
---
kind: Service
apiVersion: v1
metadata:
  name: mysql-$app_name
  namespace: $namespace
  labels:
    app: mysql-$app_name
    app.kubernetes.io/managed-by: Helm
  annotations:
    kubesphere.io/creator: admin
spec:
  ports:
    - name: mysql
      protocol: TCP
      port: 3306
      targetPort: mysql
  selector:
    app: mysql-$app_name
  type: NodePort
  sessionAffinity: None
---
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: mysql-$app_name
  namespace: $namespace
  labels:
    app: mysql-$app_name
    app.kubernetes.io/managed-by: Helm
  annotations:
    kubesphere.io/creator: admin
spec:
  replicas: 0
  selector:
    matchLabels:
      app: mysql-$app_name
  template:
    metadata:
      labels:
        app: mysql-$app_name
    spec:
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: mysql-$app_name
        - name: config
          configMap:
            name: mysql-config-$app_name
      initContainers:
        - name: remove-lost-found
          image: '10.30.30.171:10880/library/busybox:1.32'
          command:
            - rm
            - '-fr'
            - /var/lib/mysql/lost+found
          resources:
            requests:
              cpu: 10m
              memory: 10Mi
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
      containers:
        - name: mysql-$app_name
          image: '10.30.30.171:10880/mysql/mysql:5.7.44'
          ports:
            - name: mysql
              containerPort: 3306
              protocol: TCP
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-$app_name
                  key: mysql-root-password
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-$app_name
                  key: mysql-password
            - name: MYSQL_USER
              value: $app_name
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
            - name: config
              mountPath: /etc/my.cnf
              subPath: mysql-config.cnf
          livenessProbe:
            exec:
              command:
                - sh
                - '-c'
                - 'mysqladmin ping -u root -p\${MYSQL_ROOT_PASSWORD}'
            initialDelaySeconds: 30
            timeoutSeconds: 5
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - sh
                - '-c'
                - 'mysqladmin ping -u root -p\${MYSQL_ROOT_PASSWORD}'
            initialDelaySeconds: 5
            timeoutSeconds: 1
            periodSeconds: 10
  serviceName: 'mysql-$app_name'
EOF

    print_success "已生成 MySQL YAML 配置文件: $MYSQL_YAML"
}

# 创建部署
create_deployment() {
    local namespace=$1
    local app_name=$2
    
    print_info "开始创建 MySQL 部署..."
    print_info "命名空间: $namespace"
    print_info "应用名称: $app_name"
    echo ""
    
    # 检查命名空间是否存在
    if ! kubectl get namespace "$namespace" &> /dev/null; then
        print_warning "命名空间 $namespace 不存在，正在创建..."
        kubectl create namespace "$namespace"
        print_success "命名空间 $namespace 创建成功"
    else
        print_info "命名空间 $namespace 已存在"
    fi
    
    # 生成动态的 mysql.yaml 文件
    generate_mysql_yaml "$namespace" "$app_name"
    
    # 应用配置
    print_debug "应用 K8S 配置..."
    if kubectl apply -f "$MYSQL_YAML"; then
        print_success "K8S 资源配置应用成功"
    else
        print_error "K8S 资源配置应用失败"
        exit 1
    fi
    
    # 等待 Pod 启动
    print_info "等待 Pod 启动..."
    if kubectl wait --for=condition=ready pod -l app=mysql-$app_name -n "$namespace" --timeout=300s 2>/dev/null; then
        print_success "MySQL Pod 启动成功"
    else
        print_warning "MySQL Pod 启动超时或失败，请手动检查"
    fi
    
    # 显示部署状态
    echo ""
    print_success "=== MySQL 部署状态 ==="
    kubectl get statefulset,svc,pods,pvc -l app=mysql-$app_name -n "$namespace"
    
    echo ""
    print_success "✅ MySQL 部署完成!"
    echo ""
    print_info "连接信息:"
    echo "  Namespace: $namespace"
    echo "  Service: mysql-$app_name"
    echo "  Port: 3306"
    echo "  StatefulSet: mysql-$app_name"
    echo "  PVC: mysql-$app_name"
    echo "  ConfigMap: mysql-config-$app_name"
    echo "  Secret: mysql-$app_name"
}

# 删除部署
delete_deployment() {
    local namespace=$1
    local app_name=$2
    
    print_warning "开始删除 MySQL 部署..."
    print_info "命名空间: $namespace"
    print_info "应用名称: $app_name"
    echo ""
    
    # 生成动态的 mysql.yaml 文件用于删除
    generate_mysql_yaml "$namespace" "$app_name"
    
    print_debug "删除 K8S 资源..."
    if kubectl delete -f "$MYSQL_YAML" --ignore-not-found=true; then
        print_success "K8S 资源删除成功"
    else
        print_error "K8S 资源删除失败"
        exit 1
    fi
    
    # 清理生成的 YAML 文件
    if [ -f "$MYSQL_YAML" ]; then
        rm -f "$MYSQL_YAML"
        print_debug "已清理临时文件: $MYSQL_YAML"
    fi
    
    # 等待资源删除完成
    print_info "等待资源清理..."
    sleep 10
    
    # 检查是否还有残留的 Pod
    local remaining_pods
    remaining_pods=$(kubectl get pods -l app=mysql-$app_name -n "$namespace" --no-headers 2>/dev/null | wc -l)
    
    if [ "$remaining_pods" -gt 0 ]; then
        print_warning "还有 Pod 在运行，强制删除..."
        kubectl delete pods -l app=mysql-$app_name -n "$namespace" --force --grace-period=0 2>/dev/null || true
    fi
    
    # 检查是否还有 PVC 残留
    local remaining_pvc
    remaining_pvc=$(kubectl get pvc -l app=mysql-$app_name -n "$namespace" --no-headers 2>/dev/null | wc -l)
    
    if [ "$remaining_pvc" -gt 0 ]; then
        print_warning "清理残留的 PVC..."
        kubectl delete pvc -l app=mysql-$app_name -n "$namespace" 2>/dev/null || true
    fi
    
    print_success "✅ MySQL 部署删除完成!"
}

# 参数检查和验证
validate_input() {
    local command=$1
    local namespace=$2
    local app_name=$3
    
    # 检查命令参数
    if [ -z "$command" ]; then
        print_error "命令参数不能为空"
        usage
    fi
    
    # 检查操作类型
    if [ "$command" != "create" ] && [ "$command" != "delete" ]; then
        print_error "无效的命令: $command"
        print_error "支持的命令: create, delete"
        usage
    fi
    
    # 检查参数数量
    if [ "$command" = "create" ]; then
        check_argument_count 2 $# "创建"
        check_argument_empty "$namespace" "namespace" "创建"
        check_argument_empty "$app_name" "app-name" "创建"
        validate_arguments "$namespace" "$app_name" "创建"
    elif [ "$command" = "delete" ]; then
        check_argument_count 2 $# "删除"
        check_argument_empty "$namespace" "namespace" "删除"
        check_argument_empty "$app_name" "app-name" "删除"
        validate_arguments "$namespace" "$app_name" "删除"
    fi
}

# 清理函数（退出时调用）
cleanup() {
    if [ -f "$MYSQL_YAML" ]; then
        rm -f "$MYSQL_YAML"
        print_debug "已清理临时文件: $MYSQL_YAML"
    fi
}

# 设置退出时清理
trap cleanup EXIT

# 主函数
main() {
    local command=$1
    local namespace=$2
    local app_name=$3
    
    # 验证输入参数
    validate_input "$@"
    
    # 检查前置条件
    check_commands
    
    if [ "$command" = "create" ]; then
        create_deployment "$namespace" "$app_name"
    elif [ "$command" = "delete" ]; then
        delete_deployment "$namespace" "$app_name"
    fi
}

# 脚本入口
if [ $# -eq 0 ]; then
    print_error "缺少命令参数"
    usage
fi

main "$@"
```
