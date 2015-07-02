#encoding:utf-8
import sys
import datetime
import random
import math

# 找到满足要求的userID，并写入txt文件


def main(version):
	starttime = datetime.datetime.now() 	
	
	print 'load data...'
	ratingList=GetRatingData()
	socialList=GetSocialData()	
	print 'get userRatingDataMapDict...'
	ratingUserSet,userRatingDataMapDict=GetUserRatingDataMapDict(ratingList)
	print 'get userSocialDataMapDict...'
	socialUserSet,userSocialDataMapDict=GetUserSocialDataMapDict(socialList)
	print 'get socialActiveUser...'
	soActiveUserList=GetSocialActiveUser(socialUserSet,userSocialDataMapDict,1)
	print 'active social user num is %d' %len(soActiveUserList)
	print 'get ratingActiveUser... '
	rtActiveUserList,itemNumList=GetRatingActiveUser(ratingUserSet,userRatingDataMapDict,1,500000)
	print 'active rating user num is %d' % len(rtActiveUserList)	
	
	# 取交集
	print 'intersect...'
	intersectUserSet= set(soActiveUserList)&set(rtActiveUserList)
	print 'intersect user num is %d' %len(intersectUserSet)
	
	finalUserSet=intersectUserSet	
	print 'final user num is %d' %len(finalUserSet)

	finalUserSet = GetRatingCountDistribution(finalUserSet,userRatingDataMapDict)
	
	print 'get final user and start to write data to txt...'
	WriteFinalUserDataToTxt(finalUserSet,version)
	
	print 'finished'	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds  

	

def WriteFinalUserDataToTxt(finalUserSet,version):
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\flixster\\commondata\\'  #f:\project\somproject
	writer=open(workPath+'rawCoreUserID'+version+'.txt','w')
	str=''
	for user in finalUserSet:
		str=user+'\n'
		writer.write(str)
	writer.close()


			
def GetRatingCountDistribution(userSet,userRatingDataMapDict):
	ratingCountDict={}.fromkeys((['1-5','5-20','20-40','40-100','100-500','500-']),0)
	userLevelDict={}
	totalItemCount=0
	maxCount=0
	lessUserList=list()
	moreUserList=list()
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
			userLevelDict.setdefault(1,list()).append(uid)
		if itemlen>5 and itemlen<=20:
			ratingCountDict['5-20']+=1
			userLevelDict.setdefault(2,list()).append(uid)		
		if itemlen>20 and itemlen<=40:
			ratingCountDict['20-40']+=1
			userLevelDict.setdefault(3,list()).append(uid)
		if itemlen>40 and itemlen<=100:
			ratingCountDict['40-100']+=1	
			userLevelDict.setdefault(4,list()).append(uid)
		if itemlen>100 and itemlen<=500:
			ratingCountDict['100-500']+=1	
			userLevelDict.setdefault(5,list()).append(uid)
		if itemlen>500:
			ratingCountDict['500-']+=1	
			userLevelDict.setdefault(6,list()).append(uid)
		
	
	for key in ratingCountDict.keys():
		count=ratingCountDict[key]
		print 'the %s is %d \n' %(key,count)
	
	print 'the avg rating is %f ' %(1.0*totalItemCount/len(userSet))
	print 'max count is %d ' % maxCount
	
	totalUserCount=0
	for key in userLevelDict.keys():
		usercount=len(userLevelDict[key])
		totalUserCount+=usercount
		print 'the %s is %d \n' %(key,usercount)
		
	# 从各自里面随机抽取n个用户
	n=10000
	combinedUserSet=set()
	for key in userLevelDict.keys():
		userList=userLevelDict[key]
		usercount=len(userList)
		newUserCount=int(round(n*usercount*1.0/totalUserCount))
		random.shuffle(userList)
		levelUserList=userList[0:newUserCount]
		combinedUserSet=combinedUserSet.union(set(levelUserList))
	
	print  ' combined user set num is %d ' % len(combinedUserSet)
	return combinedUserSet
	
		
def GetSocialActiveUser(userSet,userSocialDataMapDict,socialThreshold):
	userList=list(userSet)
	activeUserList=list()
	for i in range(len(userList)):
		uid=userList[i]
		socialCount=userSocialDataMapDict[uid]
		if socialCount>=socialThreshold:
			activeUserList.append(uid)
	return activeUserList
	
# 获得社交数据里涉及到的user，及他们的社交个数	
def GetUserSocialDataMapDict(socialList):
	socialUserSet=set()
	# 映射每个用户与其所有的数据
	userSocialDataMapDict=dict()
	for line in socialList:
		data=line[:-1].split('\t')
		origUser=data[0]
		targetUser=data[1]
		socialUserSet.add(origUser)
		socialUserSet.add(targetUser)
		userSocialDataMapDict.setdefault(origUser,0)
		userSocialDataMapDict.setdefault(targetUser,0)
		userSocialDataMapDict[origUser]+=1
		userSocialDataMapDict[targetUser]+=1
		
	# 按link数排序
	# userSocialDataMapDict=sorted(userSocialDataMapDict.iteritems(),key=lambda d:d[1],reverse=True)
	return (socialUserSet,userSocialDataMapDict)
	
def GetRatingActiveUser(userSet,userDataMapDict,downside,upside):
	userList=list(userSet)
	activeUserList=list()
	itemNumList=list()
	for i in range(len(userList)):
		uid=userList[i]
		userData=userDataMapDict[uid]
		itemSet=set()
		for line in userData:
			data=line.split('\t')
			item=data[1]
			itemSet.add(item)
		itemlen=len(itemSet)
		if itemlen>=downside and itemlen<=upside:
			activeUserList.append(uid)
			itemNumList.append(itemlen)

	return (activeUserList,itemNumList)
	
# 获得评分数据里涉及到的user，及他们的打分数据
def GetUserRatingDataMapDict(totalDataList):
	userDataMapDict=dict()
	for line in totalDataList:
		data=line.split('\t')
		uid=data[0]
		userDataMapDict.setdefault(uid,list()).append(line)
		
	userSet=set(userDataMapDict.keys())
	return 	(userSet,userDataMapDict)

	
def GetRatingData():
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\flixster\\'  #f:\project\somproject
	f=file(workPath+'ratings.txt','r')
	ratingList=f.readlines()
	f.close()
	return ratingList

def GetSocialData():
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\flixster\\'  #f:\project\somproject
	ff=file(workPath+'links.txt','r')
	socialList=ff.readlines()
	ff.close()
	return socialList


if __name__=='__main__':
	main()