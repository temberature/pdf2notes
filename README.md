# pdf2notes
extract pdf notes to atomic notes

提取pdf笔记为原子笔记

## install guide
* （windows 10 recommended）
* install PowerShell 7
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2
* install python and pip
* under project root directory in PowerShell execute 
```PowerShell
pip install -r requirements.txt -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
```
* openPage-Readme.txt

## user guide

```PowerShell
.\pdf2notes.ps1 -pdfpattern .\pdfs\*.pdf -mdLoc ".\notebox\"
```
pay attention to slash

## 安装指南
* （win10上经过比较充分的测试）
* 安装PowerShell 7
https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2
* 安装python以及pip
* PowerShell 里，在项目根目录执行
```PowerShell
pip install -r requirements.txt -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
```
* openPage-Readme.txt

## 使用指南

```PowerShell
.\pdf2notes.ps1 -pdfpattern .\pdfs\*.pdf -mdLoc ".\notebox\"
```
注意斜杠的有无


