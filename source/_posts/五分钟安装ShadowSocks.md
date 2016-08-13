---
title: 五分钟安装ShadowSocks
date: 2/21/2016 12:47:11 AM 
tags: 
- shadowsocks
- docker
category: 配置管理
toc: true
---
作为一名码农，访问墙外的资源是一个基本需求，而ShadowSocks就能满足我们这个基本需求。
这篇博文只为记录在[DigitalOcean](http://www.digitalocean.com/?refcode=3436a2bbee6d)的VPS上通过*Docker*快速安装*ShadowSocks*的过程。该VPS运行Ubuntu 15.10系统。

### 安装Docker
确定系统内核版本是3.10或者是更新的版本。
``` bash
$ uname -r
$ 4.2.0-27-generic

$ apt-get update
$ apt-get install docker.io
```
### 安装并启动ShadowSocks
``` bash
$ docker pull oddrationale/docker-shadowsocks
$ docker run -d -p 8388:8388 --restart=always --name=shadowsocks oddrationale/docker-shadowsocks -s 0.0.0.0 -p 8388 -k ****** -m aes-256-cfb
```

最后在电脑或者移动设备上安装对应的ShadowSocks客户端，进行相应的简单配置，就可以自由冲浪啦。
