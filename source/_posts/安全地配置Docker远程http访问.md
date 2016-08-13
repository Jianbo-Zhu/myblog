---
title: 安全地配置Docker远程http访问
toc: true
date: 2016-08-13 11:30:28
tags:
  - Docker
  - CA
  - SSL
category: 配置管理
---
### 启用Docker远程http接口
默认情况下，Docker守护进程Unix socket（/var/run/docker.sock）来进行本地进程通信，而不会监听任何端口，因此只能在本地使用docker客户端或者使用Docker API进行操作。如果想在其他主机上操作Docker主机，就需要让Docker守护进程打开一个HTTP Socket，这样才能实现远程通信。
编辑docker的配置文件/etc/default/docker修改DOCKER_OPTS成
```
#同时监听本地unix socket和远程http socket（2376）
DOCKER_OPTS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2376"
```
然后重新启动docker守护进程。
```
sudo service docker restart
```
至此如果服务器启用了防火墙，只要把2376端口开放既可以在其他主机访问本docker实例了。
例如：
```
DOCKER_HOST=$host:2376 docker ps
```

### 启用TLS
但是目前位置所有知道该docker主机地址和端口的人都可以访问，显然这是个大问题。接下来我们启用TLS证书来保护该docker实例，我们自己会成为证书颁发机构(CA)，同时生成服务器端的证书和客户端用于认证的证书。首先我们生成作为证书颁发机构用于签发证书的私钥和公钥。
```
# openssl genrsa -aes256 -out ca-key.pem 4096
Generating RSA private key, 4096 bit long modulus
.................................................................................................................................................++
.........................................++
e is 65537 (0x10001)
Enter pass phrase for ca-key.pem:
Verifying - Enter pass phrase for ca-key.pem:


# openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
Enter pass phrase for ca-key.pem:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CN
State or Province Name (full name) [Some-State]:Zhejiang
Locality Name (eg, city) []:Hangzhou
Organization Name (eg, company) [Internet Widgits Pty Ltd]:zjbonline.com
Organizational Unit Name (eg, section) []:marketing
Common Name (e.g. server FQDN or YOUR name) []:www.zjbonline.com        
Email Address []:zjb@zjbonline.com
```
现在我们有了用于签发证书的公钥(ca.pem)和私钥(ca-key.pem)，接下来我们生成用于server端的私钥以及证书签名请求(CSR)。
```
# openssl genrsa -out server-key.pem 4096
Generating RSA private key, 4096 bit long modulus
..................................................................++
..................................................................................................................................................................................++
e is 65537 (0x10001)

# openssl req -subj "/CN=www.zjbonline.com" -sha256 -new -key server-key.pem -out server.csr
```
接着进行数字签名。
```
# openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
>   -CAcreateserial -out server-cert.pem
Signature ok
subject=/CN=www.zjbonline.com
Getting CA Private Key
Enter pass phrase for ca-key.pem:
```
现在我们获得了用于server端的证书：server-cert.pem。
同样的方法生成用于客户端认证的证书。
```
# openssl genrsa -out key.pem 4096
# openssl req -subj '/CN=client' -new -key key.pem -out client.csr
# echo extendedKeyUsage = clientAuth > extfile.cnf
# openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf
```
好了，现在我们修改docker的启动选项，使其只接受拥有我们的CA授权的证书的客户端连接。
修改/etc/default/docker的DOCKER_OPTS参数为
```
DOCKER_OPTS="-H unix:///var/run/docker.sock --tlsverify --tlscacert=/etc/default/docker.d/ca.pem --tlscert=/etc/default/docker.d/server-cert.pem --tlskey=/etc/default/docker.d/server-key.pem -H tcp://0.0.0.0:2376"
```
现在我们尝试通过远程接口访问docker守护进程，我们看到了一个TLS有关的错误（如下所示），说明我们的保护已经生效了，必须自己人（经认证的客户端）才可以访问。
```
# DOCKER_HOST=www.zjbonline.com:2376 docker ps
Get http://www.zjbonline.com:2376/v1.21/containers/json: malformed HTTP response "\x15\x03\x01\x00\x02\x02".
* Are you trying to connect to a TLS-enabled daemon without TLS?
```
然后我们通过证书再次访问，看看结果如何。
```
# DOCKER_HOST=mynas:2376 docker --tlsverify --tlscacert=/etc/default/docker.d/ca.pem --tlscert=/etc/default/docker.d/cert.pem --tlskey=/etc/default/docker.d/key.pem ps
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS                                                         NAMES
9820c8c9f726        dperson/transmission   "transmission.sh"   7 months ago        Up 22 minutes       0.0.0.0:9091->9091/tcp, 0.0.0.0:51413->51413/tcp, 51413/udp   transmission
```
跟我们期望的结果完全一致，但是每次命令都需要输入这么一长窜，实在是不方便，我们稍做调整，就不用每次都输入这么多了。
```
# mkdir -pv ~/.docker
# cp -v {ca,cert,key}.pem ~/.docker
# export DOCKER_HOST=tcp://www.zjbonline.com:2376 DOCKER_TLS_VERIFY=1

# docker ps
CONTAINER ID        IMAGE                  COMMAND             CREATED             STATUS              PORTS                                                         NAMES
9820c8c9f726        dperson/transmission   "transmission.sh"   7 months ago        Up 26 minutes       0.0.0.0:9091->9091/tcp, 0.0.0.0:51413->51413/tcp, 51413/udp   transmission
```
这下是不是简洁多了。完美～
