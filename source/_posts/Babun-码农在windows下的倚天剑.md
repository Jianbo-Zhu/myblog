---
title: Babun - 码农在windows下的倚天剑
date: 2016-02-21 01:30:50
tags: babun
category: 工具框架
toc: true
---
感谢cygwin让码农在windows下也用上了linux下才有的强大脚本和实用文本处理工具。而Babun则在此基础上带来了更多让码农们爱不释手的新特性。

### 安装babun
从http://babun.github.io 下载安装包，解压并且执行install.bat文件。几分钟后babun就自动起来了，程序会被安装到*%USERPROFILE%\.babun*下面。
### 实用特性
#### Cygwin
babun的核心还是cygwin，不同的是，babun对cygwin做了预先配置，使得cygwin不像原来那么难用。而且babun还新增加了许多功能。
#### pact包管理器
类似ubuntu下的apt-get或者yum，pact使得安装/查找/升级/删除cygwin的软件包变得前所未有的简单。
``` bash
{ ~ }  ? pact -h                                                                                               ~
pact: Installs and removes Cygwin packages.

Usage:
  "pact install <package names>" to install given packages
  "pact remove <package names>" to remove given packages
  "pact update <package names>" to update given packages
  "pact show" to show installed packages
  "pact find <patterns>" to find packages matching patterns
  "pact describe <patterns>" to describe packages matching patterns
  "pact packageof <commands or files>" to locate parent packages
  "pact invalidate" to invalidate pact caches (setup.ini, etc.)
Options:
  --mirror, -m <url> : set mirror
  --invalidate, -i       : invalidates pact caches (setup.ini, etc.)
  --force, -f : force the execution
  --help
  --version
```
#### 集成常用开发工具
babun默认提供了程序员常用的开发工具，使得苦逼的码农生活稍微变得轻松一些。这些工具包括：
- 开发语言类（Python, Perl等）
- unix工具（grep, wget, curl等）
- vcs(svn, git)
- oh-my-zsh

#### 基于插件的架构
babun的大多数功能都是通过插件的形式实现的，起核心只包括预先配置好的cygwin以及少量的脚本。这种基于插件的架构，使得babun可以保持非常简洁，而且可以利用社区的力量不断增加新的功能。
#### 自动更新
自动更新是个非常核心的功能。不但方便快捷，而且每次更新不会对原来的配置造成影响。
