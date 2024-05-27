#!/bin/bash
echo "更新系统 update "
yum update  -y
yum upgrade -y
echo "关闭防火墙"
systemctl stop firewalld
systemctl status firewalld

echo "getenforce"
getenforce
echo "getenforce"
swapoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab
echo "vm.swappiness=0" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
sed -i 's$/dev/mapper/centos-swap$#/dev/mapper/centos-swap$g' /etc/fstab
free -m
yum -y install chrony
sed -i.bak '3,6d' /etc/chrony.conf && sed -i '3cserver ntp1.aliyun.com iburst' \
/etc/chrony.conf
systemctl start chronyd && systemctl enable chronyd 
echo "k8s.conf"
cat >/etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
modprobe br_netfilter && sysctl -p /etc/sysctl.d/k8s.conf
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
echo "ipvs.modules"
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
echo "ipset ipvsadm"
yum -y install ipset ipvsadm

echo "conntrack"
yum install -y ebtables socat ipset conntrack
echo "新增docker源"
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
echo "docker前置"
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum makecache fast -y
echo "卸载Docker"
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
#yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin 
#systemctl enable docker && systemctl start docker
#cat > /etc/docker/daemon.json <<EOF
#{
#    "registry-mirrors": ["https://gqk8w9va.mirror.aliyuncs.com"]
#}
#EOF

#sed -i.bak "s#^ExecStart=/usr/bin/dockerd.*#ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd#g" /usr/lib/systemd/system/docker.service
echo "重启Docker"
#systemctl daemon-reload
#systemctl restart docker
echo "查看Docker安装信息"
#docker info|grep "Registry Mirrors" -A 1

echo "新增kubernetes安装源信息"
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum makecache fast -y

echo "cat >> /etc/hosts << EOF
 192.168.164.129 k8s-master
 192.168.164.129 k8s-worker1
 192.168.164.129 k8s-worker2
EOF"
echo "请修改您需要安装的版本"
export KKZONE=cn
echo "yum install -y kubeadm-1.20.6 kubelet-1.20.6 kubectl-1.20.6"
echo "systemctl enable --now kubelet"
echo "systemctl start  kubelet"

echo "前置工作完成"
export KKZONE=cn
echo "k8s-master单独执行 "
echo "kubeadm init \
  --apiserver-advertise-address=192.168.1.100 \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v1.20.6 \
  --service-cidr=10.96.0.0/12 \
  --pod-network-cidr=10.244.0.0/16 \
  --v=9"
  - {name: node1, address: 172.16.0.2, internalAddress: 172.16.0.2, user: ubuntu, password: "Qcloud@123"}
    - {name: k8s-master, address: 192.168.1.124, internalAddress: 192.168.1.124, user: root password: root}
    - {name: k8s-worker1, address: 192.168.1.125, internalAddress: 192.168.1.125, user: root password: root}
    - {name: k8s-worker2, address: 192.168.1.126, internalAddress: 192.168.1.126, user: root password: root}



