#encoding:utf-8
import sys

# 给百度评分数据去重

codePath=sys.path[0]
s=codePath.split('\\')
workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\'  #f:\project\somproject
f=file(workPath+'training_set.txt','r')
dataList=f.readlines()
f.close()

writer=open(workPath+'train_set.txt','w')

dataSet=set()
for line in dataList:
	dataSet.add(line)
simplifiedDataList=list(dataSet)
simplifiedDataList.sort()
count=0
for line in simplifiedDataList:
	writer.write(line)
	count=count+1
	
writer.close()
print count
print 'ok~'