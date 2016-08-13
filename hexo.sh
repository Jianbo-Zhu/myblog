#!/bin/sh

#生成静态页面

hexo generate
#将html目录加入git版本管理
git add html

git commit -am "Blog updated"

git push github-ssh master
