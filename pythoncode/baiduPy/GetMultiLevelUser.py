#encoding:utf-8
import sys
import datetime



def main():
	print 'load data...'
	ratingList=GetRatingData()
	coreUserList=GetCoreUserID()
	
	print 'get userRatingDataMapDict...'
	ratingUserSet,userRatingDataMapDict=GetUserRatingDataMapDict(ratingList)
	
	print 'get the less and more user...'
	userLevelList=GetRatingCountDistribution(coreUserList,userRatingDataMapDict)
	
	print 'write user level  to txt...'
	WriteUserIDToTxt(userLevelList)
	
	print 'finished...'
	
def WriteUserIDToTxt(userLevelList):
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\commondata\\'  #f:\project\somproject
	
	userLevelWriter=open(workPath+'userLevel.txt','w')
	#排序
	userLevelList.sort(key=lambda x:x[1])
	# print userLevelList
	dataline=''
	for data in userLevelList:
		user = data[0]
		level =data[1]
		dataline=user+'\t'+level+'\n'
		userLevelWriter.write(dataline)
		
	userLevelWriter.close()
	
	
def GetRatingCountDistribution(userSet,userRatingDataMapDict):
	ratingCountDict={}.fromkeys((['1-5','5-20','20-40','40-100','100-500','500-']),0)
	totalItemCount=0
	maxCount=0
	
	userLevelList=[]
	
	for uid in userSet:
		userData=userRatingDataMapDict[uid]
		itemSet=set()
		for line in userData:
			data=line.split('\t')
			item=data[1]
			itemSet.add(item)
		itemlen=len(itemSet)
		totalItemCount+=itemlen
		if itemlen>maxCount:
			maxCount=itemlen
		if itemlen>=1 and itemlen<=5:
			ratingCountDict['1-5']+=1
			userLevelList.append([uid,'1'])
		elif itemlen>5 and itemlen<=20:
			ratingCountDict['5-20']+=1	
			userLevelList.append((uid,'2'))
		elif itemlen>20 and itemlen<=40:
			ratingCountDict['20-40']+=1	
			userLevelList.append((uid,'3'))
		elif itemlen>40 and itemlen<=100:
			ratingCountDict['40-100']+=1	
			userLevelList.append((uid,'4'))
		elif itemlen>100 and itemlen<=500:
			ratingCountDict['100-500']+=1	
			userLevelList.append((uid,'5'))
		elif itemlen>500 :
			ratingCountDict['500-']+=1	
			userLevelList.append((uid,'6'))
		
	for key in ratingCountDict.keys():
		count=ratingCountDict[key]
		print 'the %s is %d \n' %(key,count)
	
	print 'the avg rating is %f ' %(1.0*totalItemCount/len(userSet))
	print 'max count is %d ' % maxCount

	return userLevelList
	
# 获得评分数据里涉及到的user，及他们的打分数据
def GetUserRatingDataMapDict(totalDataList):
	userDataMapDict = dict()
	for line in totalDataList:
		data = line.split('\t')
		uid = data[0]
		userDataMapDict.setdefault(uid,list()).append(line)

	userSet = set(userDataMapDict.keys())
	return 	(userSet, userDataMapDict)

def GetRatingData():
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\'  #f:\project\somproject
	f=file(workPath+'train_set.txt','r')
	ratingList=f.readlines()
	f.close()
	return ratingList

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


if __name__=='__main__':
	main()