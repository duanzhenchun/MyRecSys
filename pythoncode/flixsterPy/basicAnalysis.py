#encoding:utf-8
import sys
import datetime  

# 统计用户数，item数和评分分布情况

def main():
	starttime = datetime.datetime.now() 
	
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\flixster\\'  #f:\project\somproject
	f=file(workPath+'ratings.txt','r')
	ratingList=f.readlines()
	f.close()
	ff=file(workPath+'links.txt','r')
	socialList=ff.readlines()
	ff.close()
	
	# ratingUserSet=RatingDataAnalysis(ratingList)
	# SocialDataAnalysis(socialList,ratingUserSet)
	
	# ratingUserSet,userRatingDataMapDict=GetUserRatingDataMapDict(ratingList)
	# finalUserSet=GetRatingCountDistribution(ratingUserSet,userRatingDataMapDict)
	
	ratingUserSet = CountRatingUser(ratingList)
	socialUserSet = CountSocialUser(socialList)
	# combUserSet = ratingUserSet.union(socialUserSet)
	print len(socialUserSet)
	
	
	ff=file(workPath+'\\commondata\\finalSocial3.txt','r')
	finalsociallist=ff.readlines()
	ff.close()
	CountAvgSocialNum(finalsociallist)
	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds  

	

def CountAvgSocialNum(socialList):
	userdict = {}
	count = 0
	for line in socialList:
		data=line[:-1].split('\t')
		origUser=data[0]
		targetUser=data[1]
		userdict.setdefault(origUser,set()).add(targetUser)
		userdict.setdefault(targetUser,set()).add(origUser)
	
	usercount = 0
	neighborcount = 0
	for key in userdict.keys():
		neighbor = userdict[key]
		usercount +=1
		neighborcount += len(neighbor)
	
	

	print 'avg is %f' % (neighborcount*1.0/usercount)
	
def CountRatingUser(ratingList):
	userSet=set()
	itemSet=set()
	for line in ratingList:
		data=line[:-2].split('\t')  #去掉末尾\n
		uid=data[0]
		userSet.add(uid)
	return userSet
	
def CountSocialUser(socialList):
	socialUserSet=set()
	for line in socialList:
		data=line[:-1].split('\t')
		origUser=data[0]
		targetUser=data[1]
		socialUserSet.add(origUser)
		socialUserSet.add(targetUser)		

	return socialUserSet	
	
	
	

def GetRatingCountDistribution(userSet,userRatingDataMapDict):
	ratingCountDict={}.fromkeys((['0-20','20-500000']),0)
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
		if itemlen>0 and itemlen<=20:
			ratingCountDict['0-20']+=1
			lessUserList.append(uid)
		elif itemlen>20 and itemlen<=500000:
			ratingCountDict['20-500000']+=1
			moreUserList.append(uid)
		
	
	for key in ratingCountDict.keys():
		count=ratingCountDict[key]
		print 'the %s is %d \n' %(key,count)
	
	print 'the avg rating is %f ' %(1.0*totalItemCount/len(userSet))
	print 'max count is %d ' % maxCount
	
	
	# 从各自里面随机抽取n个用户
	n=5000
	lessUserList=lessUserList[0:n]
	moreUserList=moreUserList[0:n]
	
	combinedUserSet=set(lessUserList).union(set(moreUserList))
	print  ' combined user set num is %d ' % len(combinedUserSet)
	return combinedUserSet	
	
	
	
	
def SocialDataAnalysis(socialList,ratingUserSet):

	socialUserSet=set()
	count=0
	for line in socialList:
		data=line[:-1].split('\t')
		origUser=data[0]
		targetUser=data[1]
		socialUserSet.add(origUser)
		socialUserSet.add(targetUser)
		if origUser in ratingUserSet and targetUser in ratingUserSet:
			count+=1
	
	print 'total social user num is %d' %len(socialUserSet)
	a=ratingUserSet & socialUserSet	
	print 'the intersect of social and rating user num is %d' %len(a)
	print 'the social link num is %d ' % count
	
def RatingDataAnalysis(ratingList):
	userSet=set()
	itemSet=set()

	ratingScaleList=['0.5','1','1.5','2','2.5','3','3.5','4','4.5','5']
	raignCountList=[0,0,0,0,0,0,0,0,0,0]
	count=0
	print raignCountList
	for line in ratingList:
		count+=1
		data=line[:-1].split('\t')  #去掉末尾\n
		uid=data[0]
		iid=data[1]
		rating=data[2]
		userSet.add(uid)
		itemSet.add(iid)
		# 返回评分对应的index
		rcIndex=ratingScaleList.index(rating)
		raignCountList[rcIndex]+=1		
	print 'the usernum is %d, the item num is %d, the total rating num is %d \n' %(len(userSet),len(itemSet),count)
	# print sum(raignCountList)
	return userSet
	
	
# 获得评分数据里涉及到的user，及他们的打分数据
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