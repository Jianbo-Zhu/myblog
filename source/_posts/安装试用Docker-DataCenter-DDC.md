---
title: 安装试用Docker DataCenter(DDC)
toc: true
date: 2016-03-09 20:56:01
tags:
  - Docker
  - Docker Datacenter
category: 配置管理
---
Docker Datacenter(DDC)正式推出已经有段时间，趁现在她还提供30天的免费试用，所以申请了一个把玩把玩。听名字一直因为是个公有云服务平台，类似阿里云那样的，其实她是提供一套软件帮助客户搭建各自的似有云平台，好似OpenStack。她包括三个收费的模块：1）Docker Universal Control Plane(Docker UCP)，这是套图形化管理界面；2)Docker Trusted Registry（DTR），授信的Docker镜像仓库；3)收费版的Docker Engine，提供技术支持的Docker引擎。
### 安装
我们会新建3个virtualbox的虚拟机，一个作为DTR，一个UCP的controller，另一个是UCP的replica，其中DTR的虚拟机我们分配了512M内存，而UCP的虚拟机给1.5G的内存。
![虚拟机分配](/content/images/2016/03/dist.jpg)
我们通过vagrant来管理这些虚拟机，喜欢docker的同学也会喜欢vagrant，他们的初衷是类似的。
#### 申请30天免费试用
首先需要一个Docker Hub的帐号，可以免费申请。申请好账户，可以自动获得一个免费的似有镜像仓库。然后就可以去https://hub.docker.com/enterprise/trial 申请免费试用。填写你的相关信息后提交就可以了。接下来就是安装三大件Docker引擎，DTR，UCP。为了安装多个引擎的节点而我又没这么多的电脑，只好安装在virtualbox的虚拟机中了。
#### 安装收费版的引擎
在提交免费试用申请表单之后，出现的页面提供两组命令（分别适用于红帽系或DEB系的系统）用户安装收费版本的引擎，如下图所示。
![安装收费版本Doker引擎](/content/images/2016/03/Install-CS-Engine.png)
不用担心这两组命令会消失，他们最终会出现在你的账户设置（settings）页面，包括30天试用的证书文件。我们需要在3台虚拟机中都安装引擎。
#### 安装DTR
安装DTR比较简单，她已经为你提供一个命令，直接运行就可以。别看命令就一个，她可干了好多事情，光光docker镜像文件就下载了7,8个。其实DTR和UCP就是几个封装好的镜像文件。
![安装DTR和UCP](/content/images/2016/03/Install-DTR-UCP.png)
安装完就可以通过http://xxx.xxx.xxx.xxx 来访问DTR的管理界面，如下图所示。
![DTR-仪表盘](/content/images/2016/03/DTR-dashboard.png)
由于我们还没有导入试用的证书文件，页面右下角会提示当前拷贝未授权，接下来我们要导入刚申请的试用证书。先登陆Docker Hub，个人设置->license菜单项下面，可以看到下面的内容，点击其中圈中的位置就可以下载证书文件，之后导入到DTR中就完成授权。
![下载证书文件](/content/images/2016/03/download-license.png)
#### 安装UCP
首先安装UCP Controller，虚拟机VM2中输入下面命令：
``` bash
sudo docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp install --host-address xxx.xxx.xxx.xxx
```
安装程序先检查系统是否兼容UCP，之后就是等待，大概几分钟后（根据网络情况可能会有差异）提示安装成功。现在可以通过浏览器访问VM2的ip地址（需要https）登陆UCP的控制界面，输入用户admin/orca登入。马上又会提示当前系统是未授权的需要上传许可证书文件。把之前下载的许可文件上传之后就可以快乐的玩耍了。
![UCP仪表盘](/content/images/2016/03/ucp-dashboard.png)
然后安装UCP的replica，并加入UCP的集群，在VM3中执行下面指令：
``` bash
sudo docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp join --replica -i --host-address xxx.xxx.xxx.xxx
```
程序提示输入UCP controller的URL，输入https://xxx.xxx.xxx.xxx (UCP controller的ip地址)，后面询问是否相信这个服务器并且继续加入UCP的集群时，输入y然后回车。后面接着需要输入UCP的管理员用户和密码，即我们之前登陆UCP的用户密码（admin/orca），同样等待几分钟后就提示输入"Additional aliases"，我们直接敲回车即可。回头我们在来看UCP的仪表盘，这时候Nodes数量已经变为2了。根据UCP的官方文档，一个UCP的集群中最多只能允许（n-1)/2个节点失效，n是该集群中controller和replica的总数，所以当n为3的时候才容许有一个节点失效。新增UCP的replica节点，就是在想加入的节点运行上面的命令即可。
![UCP仪表盘2](/content/images/2016/03/ucp-dashboard2.png)
到此为止，安装过程就结束了。注意到我们的DTR节点并没有自动出现在UCP的仪表盘，接下来我们要研究下如何将其他的Docker引擎节点也加入到UCP的管理之下。
### 初识Docker Datacenter（DDC）
#### Hello World
依照惯例我们先向世界问好，如下图所示，初步验证通过。
![Hello World!](/content/images/2016/03/hello-world.png)
#### 管理新节点
接下来我们再新建一个虚拟机，给予512M的内存，同样方法安装Docker引擎，我们要把这个新的节点加入到UCP的管理之下。UCP底层也是通过Docker Swarm来管理Docker集群的，所以这个问题就回到了如何建立Swarm集群。仔细查看UCP Controller上的容器，我们会发现有两个容器分别名为*ucp-swarm-manager*和*ucp-kv*，再看他们的启动命令，大致猜测这个集群采用了需要TLS认证的键值发现机制。但是在DDC中不需要这么麻烦，UCP提供了更简单的命令来达到同样的目的。
``` bash
sudo docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp join -i --host-address xxx.xxx.xxx.xxx
```
什么这不是跟上面增加ucp replia节点一样么？差不多，但不完全一样，注意到我们这个命令少了*--replica*参数了么？！就这么简单，ucp帮我们搞定了所有的认证相关的步骤。过程中，会提示输入ucp controller的地址，以及管理员账户和密码，其他的只要yes或者直接回车就搞定了。重复以上过程，我们再加入一个节点。到目前位置我们有4个节点了（一个ucp controller，一个ucp replica以及两个普通的节点），如下图所示。
![四个节点的UCP](/content/images/2016/03/ucp-nodes.png)
#### 搭建Elastic Search的集群
现在我们尝试通过ucp来搭建一个由五个节点组成的elasticsearch集群。首先登陆ucp的管理界面，选择“Containers”菜单。指定image名字为*elasticsearch*，容器名字为*elasticsearch*，添加两个volumes，分别为*/tmp:/usr/share/elasticsearch/data*和*/tmp:/usr/share/elasticsearch/config*，然后点击“Run Container”，之后就是静静等待下载镜像并启动。经过几分钟或者十几分钟后（根据网络情况会有差异），名为elasticsearch的容器起来了，运行在一个普通节点上。接下来我们回到“Container”菜单，单击*elasticsearch*容器，进入该容器的详情界面，右上角有4个蓝色的按钮，点击其中的“Scale”，然后在弹出框中输入3，点击“Scale”，结果是没有结果，没有按照预期起来3个elasticsearch的容器，不清楚发生了什么。猜测是因为我们指定了容器的名称，当要起来3个的时候，DDC尝试用相同的名字去启动另外2个容器的时候发现名字冲突了，所以失败了。当然这只是猜测，我们之后回来在看这个问题。
### 小节
目前为止我们还没有用到DTR，我会在后续的文章中专门介绍DTR的使用以及与UCP的集成。总之DDC初步使用的感觉是 - 
1. 提供了一个图形化的界面可以让运维甚至开发人员直观的看到swarm集群的状态，有多少节点，多少个镜像，多少个运行中的容器，CPU以及内存的使用情况；
2. 可以通过图形界面来进行简单的镜像以及容器的管理；
3. 提供用户与权限管理，使得开发人员或者测试或产品人员通过自主服务来部署管理应用；
4. 对我来说最有用的，就是简化了将节点纳入集群管理的过程；
5. 在运行的容器详情界面提供了一个console的功能，可以让管理人员直接在网页登陆到容器中，执行命令行操作，这个功能有的时候是非常好用的。

然而对于上百个甚至上千个节点的集群，管理人员肯定还是得用脚本或API的方式来进行管理。由于使用环境是基于假设，而且个人心得跟经验有关，所以本文观点难免有局限。




