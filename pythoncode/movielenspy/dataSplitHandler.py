#encoding:utf-8
import sys
import datetime
import random
# 通过已经找到的finalUser，从rating和link数据集中提取出他们的信息
# 并且划分为训练集和测试集

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
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\movielens\\commondata\\'  #f:\project\somproject
	f=file(workPath+'ratings.dat','r')
	ratingList=f.readlines()
	f.close()

	userSet,userDataMapDict = GetUserRatingDataMapDict(ratingList)
	
	trainWriter1=open(workPath+'trainSet1.txt','w')
	testWriter1=open(workPath+'testSet1.txt','w')
	
	trainWriter2=open(workPath+'trainSet2.txt','w')
	testWriter2=open(workPath+'testSet2.txt','w')
	
	trainWriter3=open(workPath+'trainSet3.txt','w')
	testWriter3=open(workPath+'testSet3.txt','w')
	
	trainWriter4=open(workPath+'trainSet4.txt','w')
	testWriter4=open(workPath+'testSet4.txt','w')
	
	trainWriter5=open(workPath+'trainSet5.txt','w')
	testWriter5=open(workPath+'testSet5.txt','w')
	
	trainWriter = [trainWriter1,trainWriter2,trainWriter3,trainWriter4,trainWriter5]
	testWriter = [testWriter1,testWriter2,testWriter3,testWriter4,testWriter5]
	
	testCount=0
	trainCount=0	

	for user in userSet:
		userDataList = userDataMapDict[user]			
		datasize = len(userDataList)
		# 取20%的数据做为测试集
		testSetSize=int(round(datasize*0.2))
		for i in range(5):	
			testData = userDataList[i*testSetSize : (i+1) * testSetSize]
			trainData=list(set(userDataList)-set(testData))			
			for line in testData:
				testWriter[i].write(line)
			for line in trainData:
				trainWriter[i].write(line)		
		
	for i in range(5):		
		trainWriter[i].close()
		testWriter[i].close()
		
	print 'finished...'

	
def GetUserRatingDataMapDict(totalDataList):
	userDataMapDict=dict()
	for line in totalDataList:
		data=line.split('\t')
		uid=data[0]
		userDataMapDict.setdefault(uid,list()).append(line)
		
	userSet=set(userDataMapDict.keys())
	return 	(userSet,userDataMapDict)




	
if __name__=='__main__':

	main()