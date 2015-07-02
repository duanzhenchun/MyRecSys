#encoding:utf-8
import sys


# 转换一下social信息的格式，转化成1-1的格式

codePath=sys.path[0]
s=codePath.split('\\')
workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\'  #f:\project\somproject
f=file(workPath+'user_social.txt','r')
socialList=f.readlines()
f.close()

writer=open(workPath+'social_set.txt','w')

for line in socialList:
	data=line[:-2].split('\t')
	origUser=data[0]
	followList=data[1].split(',')
	for follow in followList:		
		str=origUser+'\t'+follow+'\n'
		writer.write(str)
writer.close()

print 'ok~'