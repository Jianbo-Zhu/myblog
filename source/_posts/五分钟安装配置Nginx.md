---
title: 五分钟安装配置Nginx
date: 2/21/2016 1:06:52 AM 
tags: 
- Nginx
- docker
category: 配置管理
toc: true
---

这篇博文只为记录在[DigitalOcean](http://www.digitalocean.com/?refcode=3436a2bbee6d)的VPS上通过*Docker*快速安装*Nginx*的过程。该VPS运行Ubuntu 15.10系统。

### 安装Docker
参考[五分钟安装ShadowSocks](/2016/02/21/五分钟安装ShadowSocks/#安装Docker)。
### 安装并启动Nginx
新建存放网站内容目录以及用户。
``` bash
$ mkdir -p /var/www/public
$ useradd -d /var/www blog #新建用户blog，并将其home目录设置为*/var/www*
$ passwd blog #设置用户blog的密码
$ chown -R blog.blog /var/www #修改/var/www的所有者为blog
```
下载并且启动Nginx的Docker容器。
``` bash
$ docker run -d -v /var/www/public:/usr/share/nginx/html:ro --name=mynginx -p 80:80 --restart=always nginx
```
大功告成。
