# -*- coding: utf-8 -*-
 
import jieba
import jieba.analyse
from optparse import OptionParser
import win32clipboard
import re
import glob
import os
# import js2py
# import links2content
# js2py.eval_js('console.log( "Hello World!" )')
# # js2py.require("links2content")
# js2py.translate_file("C:\\Users\\16052\\SDD\\JS\\links2content.js", "C:\\Users\\16052\\SDD\\JS\\links2content.py")

def content2links(content, topK):
    content = contentMergeEmbeds(content)
    print(content)
    tags = jieba.analyse.textrank(content, topK)
    links = ''
    for idx, tag in enumerate(tags):
        if idx == 0:
            prefix = ''
        else:
            prefix = ','
        links += prefix + '[[' + tag + ']]'
    return links

def contentMergeEmbeds(content):
    m = re.findall('\[\[(.*)\]\]', content)
    for root, dirs, files in os.walk("Z:\pdfnotes\pdfnotes"):
        # print('Looking in:',root, dirs, files)
        for file in files:
            if(file in m):
                with open(root + '\\' + file, 'r+', encoding='UTF-8') as f:
                    content = content.replace('![[' + file + ']]', ''.join(f.readlines()))
    return content;

def contentAddlinks(content):
    lines = content.splitlines(True)
    front = ''.join(lines[0:4])
    if(re.match('^\[\[.*\]\]$', lines[4]) is None):
        main = ''.join(lines[4:])
    else:
        main = ''.join(lines[5:])
    
    links = content2links(main, 5)
    content = front + links + '\n' + main
    return content


def fileAddlinks(filename):
    # print(filename)
    f = open(filename, 'r+', encoding='UTF-8')
    content = f.read()
    content = contentAddlinks(content)
    print(content)
    f.seek(0)
    f.write(content)
    f.truncate()
    f.close()


USAGE = "usage:    python extract_tags.py [file name] -k [top k]"

parser = OptionParser(USAGE)
parser.add_option("-k", dest="topK")
opt, args = parser.parse_args()

if opt.topK is None:
    topK = 5
else:
    topK = int(opt.topK)

if len(args) > 0:
    path = args[0]


if len(args) < 1:
    win32clipboard.OpenClipboard()
    content = win32clipboard.GetClipboardData()

    links = content2links(content, 10)
    # print(links)

    win32clipboard.EmptyClipboard()
    win32clipboard.SetClipboardText(links)
    win32clipboard.CloseClipboard()
elif os.path.isdir(path):
    print("\nIt is a directory")
    for filename in glob.iglob(path + '**/*.md', recursive=True):
        fileAddlinks(filename)
elif os.path.isfile(path):
    print("\nIt is a normal file")
    fileAddlinks(path)
else:
    print("\nIt is a string")
    print('unknown')
