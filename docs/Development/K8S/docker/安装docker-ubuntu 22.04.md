#安装docker，基于ubuntu 22.04 

参考连接 [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
```sh
# Uninstall old versions
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the Docker packages
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

参考连接 [Install the Compose plugin](https://docs.docker.com/compose/install/linux/#install-using-the-repository)
```sh
# For Ubuntu and Debian, run:
sudo apt-get update
sudo apt-get install docker-compose-plugin
```


```sh
# 创建文件夹并赋权
sudo mkdir ~/mssql-test/{mssql,backups}  -p
sudo chown -R 10001:0 ~/mssql-test

# 拉取镜像
sudo docker pull mcr.microsoft.com/mssql/server:2019-latest

# 部署
sudo docker run \
    -e "ACCEPT_EULA=Y" \
    -e "MSSQL_SA_PASSWORD=P@88w0rd!" \
    -p 1433:1433 \
    -v ~/mssql-test/mssql:/var/opt/mssql \
    -v ~/mssql-test/backups:/var/backups \
    --name mssql-test \
    --hostname mssql-test  \
    -d \
    mcr.microsoft.com/mssql/server:2019-latest
```