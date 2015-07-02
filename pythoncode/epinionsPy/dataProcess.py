#encoding:utf-8
import sys


# 转换一下social信息的格式，转化成1-1的格式

codePath=sys.path[0]
s=codePath.split('\\')
workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\epinions\\'  #f:\project\somproject

''' process the rating data'''
# f=file(workPath+'orig_ratings_data.txt','r')
# ratingList=f.readlines()
# f.close()
# ratingWriter=open(workPath+'ratings_data.txt','w')
# dataCount=0
# for line in ratingList:
	# data = line[:-1].split()
	# uid = data[0]
	# iid = data[1]
	# rating = data[2]
	# writeStr = uid+'\t'+iid+'\t'+rating+'\n'
	# ratingWriter.write(writeStr)
	# dataCount +=1
# ratingWriter.close()
# print 'datacount is %d' % dataCount
	
	
''' process the social data'''	
f=file(workPath+'orig_trust_data.txt','r')
socialList=f.readlines()
f.close()
socialWriter=open(workPath+'trust_data.txt','w')

for line in socialList:
	data=line[:-1].split()
	origUser = data[0]
	targetUser = data[1]	
	writeStr=origUser+'\t'+targetUser+'\n'
	socialWriter.write(writeStr)

socialWriter.close()

print 'ok~'