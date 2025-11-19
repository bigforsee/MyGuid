# docker-compose部署gitlab

文件传至 `/usr/local/bin/`  然后赋权

```shell
mv docker-compose /usr/local/bin
sudo chmod +x /usr/local/bin/docker-compose
echo '软连接'
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
echo '查看版本'
docker-compose version
```

- 或者先赋权然后移动到可以执行目录既可以

  ```
  ehco $PATH
  chmod +x docker-compose
  mv docker-compose /usr/bin
  ```

  

vi docker-compose.yaml

```yaml
version: '3.1'
services:
  gitlab:
    image: 'gitlab/gitlab-ce:latest'
    container_name: gitlab
    restart: always
    environment:
      GITLAB_OMNIBUS_CONFIG: |
          external_url 'http://192.168.183.136:8929'
          gitlab_rails['gitlab_shell_ssh_port'] = 2236
    ports:
      - '8929:8929'
      - '2224:2224'
    volumes:
      - './config:/etc/gitlab'
      - './logs:/etc/log/gitlab'
      - './data:/etc/opt/gitlab'

```



```shell
ehco "执行yml部署gitlab"
docker-compose up -d 
```



等待部署成功访问地址 `http://192.168.183.136:8929` 如果可以访问了就去内如查找密码

```
ehco `进入容器 gitlab`
docker exec -it gitlab bash
ehco `查找密码`
cat /etc/gitlab/initial_root_password
#范例 Password: /UAJNlgyjUEs1/z9M9FnRRDwsxpLUZRsqmROb8zvsls=
```



修改密码  在右上角点击 `Preferences` 左边找到password

我的账号密码为root    zxh123456  