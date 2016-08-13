---
title: 安装配置Hexo-一个静态blog框架
date: 2016-02-20 22:18:37
tags:
 - hexo
category: 配置管理
author: 悟静
toc: true
---

Hexo是一个基于NodeJS的静态blog框架，本文用于记录在windows环境安装配置Hexo的过程。
基本构想是在个人电脑上安装Hexo，撰写并且调试日志，然后生成静态页面，最后部署到blog服务器上。Blog服务器是部署在[DigitalOcean](http://www.digitalocean.com/?refcode=3436a2bbee6d)上的Nginx。

### 安装NodeJS
- 下载并且安装[git](https://git-scm.com/download/win)
- 下载并且安装[Node](http://nodejs.org/)

### 安装Hexo
``` bash
$ npm install -g hexo-cli
```
### 配置主题theme
个人比较喜欢简洁朴素的风格，所以选择了这款主题。
``` bash
$ git clone https://github.com/tufu9441/maupassant-hexo.git themes/maupassant
$ npm install hexo-renderer-sass --save
$ npm install hexo-renderer-jade --save
```
修改根目录下的*_config.yml*文件，将theme设置成“maupassant"
``` yml
theme: maupassant
```
接下来就是启动Hexo服务器，撰写日志。
``` bash
$ hexo server -p 5000 #启动hexo服务器，监听端口5000
```
### 一键部署
日志写完本地检查测试通过，就要上传至blog服务器端。这里我通过rsync将生成的静态页面同步到blog服务器上的对应路径。
安装插件*hexo-deployer-rsync*
``` bash
$ npm install hexo-deployer-rsync --save
```
再次修改*_config.yml*文件，增加*deploy*配置项。
``` yml
deploy: 
	type: rsync
	host: <blog server hostname or ip>
	user: <user>
	root: <root>
	port: 22
	delete: true
	args: 
	verbose: true
	ignore_errors: false
```
**注意：尽管有些属性有默认值，但是还是得全部写上，否则会出现莫名的问题。**
最后通过下面命令生成静态页面并且同步至blog服务器。
``` bash
$ hexo generate --deploy
```
之后，每次完成一篇日志只需要执行下面命令即可。
``` bash
$ hexo generate --deploy
```
### 通过Jenkins部署到DigitalOcean的VPS上
1. 安装*Mask Passwords* Jenkins插件
2. 新建一个Jenkins任务，分两个步骤
 * 首先调用hexo命令生成静态页面
``` bash
#step - generete
cd %bloghome%
hexo generate
```
 * 然后通过pscp将生成的静态页面上传至服务器
``` bash
#step 2 - upload
pscp -r -pw %password% public xxx@xxx.com:/html/folder
```

