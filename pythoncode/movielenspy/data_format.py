#encoding:utf-8
import sys



# 修改数据的格式，以便于应用于matlab



codePath=sys.path[0]
s=codePath.split('\\')
workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\movielens\\commondata\\'  #f:\project\somproject
f=file(workPath+'testSet5.txt','r')
ratingList=f.readlines()
f.close()

datawriter = open(workPath+'newtestSet5.txt','w')
for line in ratingList:
	data = line[:-1].split('::')
	uid = data[0]
	iid = data[1]
	rating = data[2]
	newline = '%s\t%s\t%s\n' %(uid,iid,rating)
	datawriter.write(newline)
datawriter.close()

print 'finished ...'