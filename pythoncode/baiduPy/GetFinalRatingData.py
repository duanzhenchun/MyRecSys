#encoding:utf-8
import sys
import datetime
import random

def main():
	starttime = datetime.datetime.now() 
	
	print 'start...'
	coreUserList=GetCoreUserID()
	ratingList=GetRatingData()
	print 'get rating data...'
	GetRatingDataAndWriteToTxt(coreUserList,ratingList)
	
	print 'finished'	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds  

	
	

def GetRatingDataAndWriteToTxt(coreUserList,ratingList):
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\commondata\\'  #f:\project\somproject
	writer=open(workPath+'finalRating.txt','w')
	count=0
	lineStoreList=[]
	for line in ratingList:
		data=line[:-1].split('\t')
		uid=data[0]
		if uid in coreUserList:
			lineStoreList.append(line)
			count+=1
	writer.writelines(lineStoreList)		
	writer.close()
	print 'total rating count is %d ' % count
	
	
def GetCoreUserID():
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\commondata\\'  #f:\project\somproject
	f=file(workPath+'coreUserID.txt','r')
	dataList=f.readlines()
	f.close()
	coreUserList=list()
	for line in dataList:
		uid=line[:-1]
		coreUserList.append(uid)
	return coreUserList	
	
def GetRatingData():
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\'  #f:\project\somproject
	f=file(workPath+'train_set.txt','r')
	ratingList=f.readlines()
	f.close()
	return ratingList
	
	
if __name__=='__main__':
	main()
	
	