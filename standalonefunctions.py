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
        if fname in line:
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

fileslist = []
for item in calledzero.keys():
  #print(item)
  fileslist.append(fullpathforfilename('.',item))

