#encoding:utf-8
import sys
import datetime
import random
# 通过已经找到的finalUser，从rating和link数据集中提取出他们的信息
# 并且划分为训练集和测试集

version = '1'

def main():
	starttime = datetime.datetime.now() 	
		
	# 划分训练集和测试集
	print 'split data...'
	SplitTrainAndTestSet()
		
	print 'finished'	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds  

	
	
def SplitTrainAndTestSet():
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\epinions\\commondata\\'  #f:\project\somproject
	f=file(workPath+'finalRating'+version+'.txt','r')
	ratingList=f.readlines()
	f.close()
	coreUserList = GetCoreUserID()
	
	userSet,userDataMapDict = GetUserRatingDataMapDict(ratingList)
	
	trainWriter=open(workPath+'trainSet'+version+'.txt','w')
	testWriter=open(workPath+'testSet'+version+'.txt','w')
	testCount=0
	trainCount=0	
	elseCount = 0
	for user in userSet:
		userDataList=userDataMapDict[user]
		ratingcount=len(userDataList)
				
		# 个数小于等于10  随机取1个当测试集
		if ratingcount<=10:
			randIdx=random.randint(0,ratingcount-1)
			testData=userDataList[randIdx:randIdx+1]
			trainData=list(set(userDataList)-set(testData))
				
		# 个数大于10 ，随机取20% 四舍五入当测试集
		elif ratingcount>10:		
			random.shuffle(userDataList)
			datasize=len(userDataList)
			# 取20%的数据做为测试集
			testSetSize=int(round(datasize*0.2))
			testData= userDataList[0:testSetSize]		
			trainData=list(set(userDataList)-set(testData))
			
		for line in testData:
			testWriter.write(line)
			testCount+=1
		for line in trainData:
			trainWriter.write(line)		
			trainCount+=1
		
			
	trainWriter.close()
	testWriter.close()
	print 'the testCount is %d , the trainCount is %d' %(testCount,trainCount)
	print 'elseCount is %d' % (elseCount)
	
def GetUserRatingDataMapDict(totalDataList):
	userDataMapDict=dict()
	for line in totalDataList:
		data=line.split('\t')
		uid=data[0]
		userDataMapDict.setdefault(uid,list()).append(line)
		
	userSet=set(userDataMapDict.keys())
	return 	(userSet,userDataMapDict)


def GetCoreUserID():
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\epinions\\commondata\\'  #f:\project\somproject
	f=file(workPath+'coreUserID'+version+'.txt','r')
	dataList=f.readlines()
	f.close()
	coreUserList=list()
	for line in dataList:
		uid=line[:-1]
		coreUserList.append(uid)
	return coreUserList		

	
if __name__=='__main__':
	main()