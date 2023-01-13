import os
from pathlib import Path

def getFuncNamesAndFileList():
  funcnames=[]
  filelist=[]
  for root,dirs,files in os.walk('.'):
    for file in files:
      if file.endswith('.m'):
        filelist.append(os.path.join(root,file))
        funcnames.append(os.path.splitext(file)[0])
  return funcnames, filelist

funcnames,funcfiles= getFuncNamesAndFileList()


def findFuncInFiles(fname,filelist):
  ct=0
  appearsin=[]
  for filePath in filelist:
    with open(filePath, 'r') as f:
      for line in f:
        line=line.strip()
        if fname in line and not line.startswith('%') and not line.startswith('function'):
            appearsin.append(filePath)
            break
  return appearsin

def writecallsbyfunc(funcnames,funcfiles):
  callsByFunc={}
  ct=0
  for fn in funcnames:
    ct= ct+1
    if ct % 100 ==0:
      print(ct," of ",len(funcnames))
    callsByFunc[fn]=findFuncInFiles(fn,funcfiles)

  with open('funcsandcalls.txt','w') as f:
    for fname,callfiles in callsByFunc.items():
      linetowrite = "{}\t{}\n".format(fname,','.join(callfiles))
      f.write(linetowrite)



#writecallsbyfunc(funcnames,funcfiles)

calledonce={}
calledzero={}
with open('funcsandcalls.txt','r') as infile:
  for l in infile:
    line = l.strip("\n")
    [k,v]= line.split('\t')
    if len(v)==0:
      items=[]
    else:
      items = v.split(',')
    m=len(items)
    if m==1:
      calledonce[k]=items
    elif m==0:
      calledzero[k]=items 


def fullpathforfilename(rootdir,fname):
  fname = fname + '.m'
  fullpath = None
  #print(fname)
  for r,ds,fs in os.walk(rootdir):
    for f in fs:
      #if f.endswith('.m'):
      #  print(f)
      if fname in f:
        #print(r)
        #print(f)
        fullpath = os.path.join(r,f)
  return fullpath

# fileslist = []

# def countStartsEnds(fname):
#   openers=('if','for','while','function','switch','classdef','enumeration','methods','properties')
#   ct=0
#   lineno=1
#   with open(fname,'r') as fin:
#     for line in fin:
#       lineno+=1
#       line=line.strip().rstrip()
#       if list(filter(line.startswith, openers)) != []:
#         if line.endswith('end'):
#           continue
#         #print(str(lineno) + '++')
#         ct=ct+1
#       elif line.startswith('end'):
#         #print(str(lineno) + '--' )
#         ct=ct-1
#   return ct

# def addEndsToFiles(fname):
#   f1 = open(fname, 'a+')
#   #f2 = open(secondfile, 'r')
 
#   # appending the contents of the second file to the first file
#   f1.write('\nend\n')
#   f1.close()

# fun,files = getFuncNamesAndFileList()
# for fil in files:
#   ct=countStartsEnds(fil)
#   if ct != 0:
#     #addEndsToFiles(fil)
#     print(ct)
#     print(fil)
#     #break
#   #print(countStartsEnds(fullpathforfilename('.',f)))
# #print(countStartsEnds('SP2_Global/SP2_ReadDefaults.m'))
import shutil

# for funname in calledzero.keys():
#   fullpath=fullpathforfilename('.',funname)
#   if 'Unused' in fullpath:
#     continue
#   shutil.move(fullpath,'./.UnusedFuncs')
import pprint
pprint.pprint(calledzero)