#!/bin/bash
echo "关闭防火墙"
systemctl stop firewalld
systemctl disable firewalld

echo "sed -i 's/enforcing/disabled/' /etc/selinux/config"
sed -i 's/enforcing/disabled/' /etc/selinux/config
setenforce 0

echo "sed -ri 's/.*swap.*/#&/' /etc/fstab"
sed -ri 's/.*swap.*/#&/' /etc/fstab

echo "/etc/sysctl.d/k8s.conf"
    cat > /etc/sysctl.d/k8s.conf <<EOF
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
EOF

echo "sysctl --system"
sysctl --system
echo "卸载docker"
sudo yum remove docker \
              docker-client \
              docker-client-latest \
              docker-common \
              docker-latest \
              docker-latest-logrotate \
              docker-logrotate \
              docker-engine

echo "安装docker源"
yum install -y  yum-utils \
device-mapper-persistent-data \
lvm2

echo " ==========================================================================================================================="
echo "yum-config-manager"
echo " ==========================================================================================================================="
sudo yum-config-manager \
--add-repo \
https://download.docker.com/linux/centos/docker-ce.repo

echo " ==========================================================================================================================="
echo "安装docker"
echo " ==========================================================================================================================="
yum -y install docker-ce docker-ce-cli containerd.io

echo " ==========================================================================================================================="
echo "$?"
echo " ==========================================================================================================================="
if [ $? -eq 0  ]; then

    echo "设置 /etc/docker/daemon.json"
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
    {
        "registry-mirrors": ["https://ke9h1pt4.mirror.aliyuncs.com"]
    }
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    sudo systemctl enable docker


    systemctl stop firewalld
    systemctl status firewalld

    getenforce

    swapoff -a
    echo "vm.swappiness=0" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf

    sed -i 's$/dev/mapper/centos-swap$#/dev/mapper/centos-swap$g' /etc/fstab
    free -m

    yum -y install chrony

    sed -i.bak '3,6d' /etc/chrony.conf && sed -i '3cserver ntp1.aliyun.com iburst' \
    /etc/chrony.conf

    systemctl start chronyd && systemctl enable chronyd

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

    chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

    yum -y install ipset ipvsadm
    yum install -y ebtables socat ipset conntrack
    yum install -y yum-utils

     cat > /etc/docker/daemon.json <<EOF
    {
        "registry-mirrors": ["https://gqk8w9va.mirror.aliyuncs.com"]
    }
EOF

    sed -i.bak "s#^ExecStart=/usr/bin/dockerd.*#ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd#g" /usr/lib/systemd/system/docker.service

    systemctl daemon-reload
    systemctl restart docker

echo "安装 cri-docker"
yum install -y wget

wget  https://ghproxy.com/https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.5/cri-dockerd-0.2.5.amd64.tgz

tar xvf cri-dockerd-0.2.5.amd64.tgz 
cp cri-dockerd/cri-dockerd  /usr/bin/
chmod +x /usr/bin/cri-dockerd

cat >  /usr/lib/systemd/system/cri-docker.service <<EOF
[Unit]
Description=CRI Interface for Docker Application Container Engine
Documentation=https://docs.mirantis.com
After=network-online.target firewalld.service docker.service
Wants=network-online.target
Requires=cri-docker.socket
 
 
[Service]
Type=notify
ExecStart=/usr/bin/cri-dockerd --network-plugin=cni --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.7
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
 
 
StartLimitBurst=3
 
 
StartLimitInterval=60s
 
 
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
 
 
TasksMax=infinity
Delegate=yes
KillMode=process
 
 
[Install]
WantedBy=multi-user.target
EOF

cat > /usr/lib/systemd/system/cri-docker.socket <<EOF
[Unit]
Description=CRI Docker Socket for the API
PartOf=cri-docker.service
 
 
[Socket]
ListenStream=%t/cri-dockerd.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker
 
 
[Install]
WantedBy=sockets.target
EOF

systemctl daemon-reload 
systemctl enable cri-docker --now

export KKZONE=cn
echo "===================================================="
echo " "
echo "==============================请手动安装kubesphere======================"
echo "curl -sfL https://get-kk.kubesphere.io | VERSION=v2.2.2 sh -"
echo "chmod +x kk"
echo "./kk create cluster --with-kubernetes v1.22.10 --with-kubesphere v3.3.0"
echo "===================================================="


#curl -sfL https://get-kk.kubesphere.io | VERSION=v2.2.2 sh -
#chmod +x kk
#./kk create cluster --with-kubernetes v1.22.10 --with-kubesphere v3.3.0


fi


#/var/lib/kubelet/
#var/lib/docker/
#Account: admin
#Password: P@88w0rd
