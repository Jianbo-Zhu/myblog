---
title: Tomcat多虚拟主机(virtual host)配置
toc: true
date: 2016-02-28 23:48:39
tags:
  - tomcat
category: 配置管理
---
一个tomcat服务器同时服务多个虚拟主机，前提是多个域名同时指向这台tomcat服务器。假如有两个域名同时指向我们的tomcat服务器-dnsname1和dnsname2，如果没有我们通过修改hosts文件来进行测试。Linux下hosts在/etc/hosts，而windows下则是C:\Windows\System32\drivers\etc\hosts。添加下面两行：
```
127.0.0.1	dnsname1
127.0.0.1	dnsname2
```
修改$TOMCAT_BASE$/conf/server.xml文件，在Engine下新建两个host元素:
``` xml
<Host name="dnsname1"  appBase="/home/user1/webapp"
      unpackWARs="true" autoDeploy="true">

  <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
         prefix="localhost_access_log_dnsname1" suffix=".txt"
         pattern="%h %l %u %t &quot;%r&quot; %s %b" />

</Host>

<Host name="dnsname2"  appBase="/home/user2/webapp"
      unpackWARs="true" autoDeploy="true">

  <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
         prefix="localhost_access_log_dnsname2" suffix=".txt"
         pattern="%h %l %u %t &quot;%r&quot; %s %b" />

</Host>
```
**appBase**分别指向了不同目录，通常是不同用户的web应用目录。
重启tomcat，通过浏览器分别访问http://dnsname1 和http://dnsname2 ，将会获得不同的页面。
