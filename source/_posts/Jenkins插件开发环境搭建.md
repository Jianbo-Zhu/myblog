---
title: Jenkins插件开发环境搭建
tags:
  - jenkins
  - plugin
category: 编程开发
toc: true
date: 2016-02-26 22:59:29
---

Jenkins是一个被广泛应用的持续集成以及配置管理的工具，对于一些复杂的项目，需要开发一些特定的插件来满足各种需求。本文记录基于IntelliJ的jenkins插件开发环境的搭建。

### 准备工作
当然，作为一名开发人员这些下面这些工具肯定已经存在了。但是为了保持本文的完整性，还是有必要再列一下。
- jdk 6+
- maven 3
  - 将maven可执行文件所在路径加入到PATH环境变量中；
  - 修改maven配置文件~/.m2/settings.xml（windows系统为%USERPROFILE%\.m2\settings.xml）

``` xml
<settings>
  <pluginGroups>
    <pluginGroup>org.jenkins-ci.tools</pluginGroup>
  </pluginGroups>

  <profiles>
    <!-- Give access to Jenkins plugins -->
    <profile>
      <id>jenkins</id>
      <activation>
        <activeByDefault>true</activeByDefault> <!-- change this to false, if you don't like to have it on per default -->
      </activation>
      <repositories>
        <repository>
          <id>repo.jenkins-ci.org</id>
          <url>http://repo.jenkins-ci.org/public/</url>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <id>repo.jenkins-ci.org</id>
          <url>http://repo.jenkins-ci.org/public/</url>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
  <mirrors>
    <mirror>
      <id>repo.jenkins-ci.org</id>
      <url>http://repo.jenkins-ci.org/public/</url>
      <mirrorOf>m.g.o-public</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```
如果你的网络处于防火墙之内，需要代理服务器才能访问外网。则加入类似下面的内容到settings.xml文件中。
``` xml
<settings>
  .
  .
  <proxies>
   <proxy>
      <id>example-proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>proxy.example.com</host>
      <port>8080</port>
      <username>proxyuser</username>
      <password>somepassword</password>
      <nonProxyHosts>www.google.com|*.example.com</nonProxyHosts>
    </proxy>
  </proxies>
  .
  .
</settings>
```
- Intellij社区版，土豪们用收费版更好。也可以用eclipse，但是个人推荐使用前者。

### 开始一个Jenkins插件开发项目

打开命令行终端，执行下面命令：
``` bash
$ mvn -U org.jenkins-ci.tools:maven-hpi-plugin:create
```
这个命令需要你输入groupid/artifactid等信息后，会自动生成一个jenkins插件项目的框架。将该项目导入IntelliJ，就可以开始Jenkins插件开发之旅了。其中这些命令会比较常用：
- mvn package #将插件打包，可以部署到Jenkins服务器上。
- mvn hpi:run #启动一个jenkins的测试环境，自动加载最新的插件代码，如此就可以快速的对修改做验证。







