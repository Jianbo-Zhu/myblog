---
title: VIM实用技巧以及插件
date: 2016-02-22 00:24:21
tags: VIM
category: 工具框架
toc: true
---
作为一名码农最痛苦的事情是写代码的过程中需要不断的切换键盘和鼠标，而VIM的最大特点就是不需要鼠标，所以我打算给VIM一个机会。而本文则是为了记录VIM的使用技巧以及插件，供往后参考，同时加强学习的效果。
### 实用技巧
#### 解决"Small version without GUI"的问题
进入VIM，输入命令*:version*，如果结果显示当前版本为"Small version without GUI",则需要安装*vim-gui-common*，否则下面的功能都无法使用。  
在Ubuntu下的安装命令为：
``` bash
sudo apt-get install vim-gui-common
```
#### 复制粘贴
vim提供多个寄存器（registry），这就意味着我们可以同时拷贝/粘贴多个内容。命令*:reg*显示当前寄存器中的内容，如下图所示，其中红色框框中的为寄存器名称或地址，可以通过该地址来指定复制到/粘贴自该寄存器。
![VI-当前寄存器中的内容](/content/images/2016/02/vi_reg.jpg)
值得注意的是从vim外部拷贝的内容（系统粘贴板）是存放在寄存器**”***中的，可以通过快捷键**“ * p**进行粘贴(依次敲入"\*p三个键)。相反需要拷贝到系统粘贴板以供其他程序使用时，可以选中内容然后通过快捷键**" * p**拷贝至系统粘贴板中。
#### 多窗口/文件(buffer)操作
现在不管多小的项目，肯定不可能是单个文件构成的，程序员往往需要同时编辑多个文件。由此多个窗口同时编辑就显得尤其重要。
vim中拆分窗口的命令为*:split*（水平拆分/上下拆分）和*:vsplit*（垂直拆分/左右拆分），快捷键分别为*ctrl+w s*和*ctrl+w v*。
在窗口键切换命令*ctrl+w h*, *ctrl+w j*, *ctrl+w k*, *ctrl+w l*, 分别切换到左边、下边、上边、右边的窗口。或者*ctrl+w ctrl+w*按顺时针切换窗口。
往往我们需要同时打开5个甚至10个以上的文件(buffer)进行操作，尽管我们可以拆分同样数量的窗口，但那时候估计会疯掉的。所以打开文件多而窗口少，就需要在打开文件间进行切换。
``` bash
:buffers, :ls, :files #显示当前打开的文件（buffer）
:b(n) #打开编号为n的文件（buffer）
```
#### 自动缩进、TAB宽度
**gg=G** - 全文自动缩进，不包括括号，在一般模式下连续输入’g’, ‘g’, ‘=’, ‘G’四个键。其中**gg**光标定位到文件开始的位置，**=**刷自动缩进命令，**G**光标移动到最后一行行首。因此这个命令就是全文自动缩进。
**=i}** - 光标所在的{}块自动缩进。
设定tab宽度以及用空格替换TAB：
``` ruby
set tabstop=4 #tab长度设为4
set shiftwidth=4 #自动缩进长度设为4 
set expandtab #tab有空格填充
set autoindent #自动缩进
set smartindent 
```
### 常用插件 
#### [pathogen](https://github.com/tpope/vim-pathogen)
管理插件的插件，其用途是管理"runtimepath"。换言之，原来vim的插件都是在一个目录下的，当插件数量很多的时候，存放插件的目录就非常混乱，维护成本很高；而pathogen可以将插件存放在各自的目录下。所以，有了pathogen，妈妈再也不用担心我把插件搞得满地都是了。
**安装**
``` bash
$ mkdir -p ~/.vim/autoload ~/.vim/bundle
$ curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
```
将下面指令加入到~/.vimrc中，如果这个文件不存在则新建一个。
``` bash
execute pathogen#infect()
```
#### [NERDTree](https://github.com/scrooloose/nerdtree)
侧栏显示目录结构，并且支持简单的文件操作。
**安装**
``` bash
$ cd ~/.vim/bundle
$ git clone https://github.com/scrooloose/nerdtree.git
```
然后重启vim，执行命令*:Helptags*,解下来大致过下他的帮助文档了解他的用法*:help NERD_tree.txt*。
其中*:NERDTree*激活侧边栏的目录显示。
如果希望vim每次起来都自动显示目录，只需要修改~/.vimrc。
``` 
autocmd vimenter * NERDTree
```
#### [vim-markdown](https://github.com/plasticboy/vim-markdown)
Vim对markdown语法支持的插件，在vim下写文档必备插件。本文也是vim+这个插件编写完成。
**安装**
``` bash
cd ~/.vim/bundle
git clone https://github.com/plasticboy/vim-markdown.git
```
禁止markdown的folding功能。
``` 
let g:vim_markdown_folding_disabled = 1
```
同样，*:Helptags*命令刷新帮助文档。
#### [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)
代码自动补全。依赖于基础开发库和cmake，以及python的头文件，在ubuntu下通过下面命令安装这些依赖。
``` bash
sudo apt-get install build-essential cmake
sudo apt-get install python-dev python3-dev
```
**安装**
``` bash
cd ~/.vim/bundle
git clone https://github.com/Valloric/YouCompleteMe.git
git submodle update --init --recursive
cd ~/.vim/bundle/YouCompleteMe
./install.py --tern-completer #自动补全javascript, 需要事先安装nodejs和npm
```
#### [emmetvim](https://github.com/mattn/emmet-vim)
这个就不多说了，vim下编辑html和css的倚天剑。
**安装**
``` bash
cd ~/.vim/bundle
git clone https://github.com/mattn/emmet-vim.git
```
重新启动VIM，输入*html:5*然后*ctrl+y*，最后按*，*(逗号)键试试看。
#### [vim-autoformat](https://github.com/Chiel92/vim-autoformat)
代码格式化，无需解释。
autoformat本身不会对代码作格式化，他只是调用第三方程序，因此根据所编辑文件类型不同，需要安装对应的第三方程序。具体什么格式对应什么程序，查看上面的官网地址。
**安装**
``` bash
cd ~/.vim/bundle
git clone https://github.com/Chiel92/vim-autoformat.git
```
为了格式化html/javascript/css文件，需要安装js-beautify。
``` bash
npm install -g js-beautify
```
重启VIM，打开某个js源码文件，敲入命令**:Autoformat**，效果如何？

