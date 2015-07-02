#encoding:utf-8
import sys
 

# 统计用户数，item数和评分分布情况

def main():
	
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\'  #f:\project\somproject
	f=file(workPath+'train_set.txt','r')
	ratingList=f.readlines()
	f.close()
	ff=file(workPath+'social_set.txt','r')
	socialList=ff.readlines()
	ff.close()
			
	# ratingUserSet=RatingDataAnalysis(ratingList)	
	# SocialDataAnalysis(socialList,ratingUserSet)
	
	ratingUserSet = CountRatingUser(ratingList)
	socialUserSet = CountSocialUser(socialList)
	combUserSet = ratingUserSet.union(socialUserSet)
	print len(combUserSet)
	
	
	ff=file(workPath+'\\commondata\\finalSocial.txt','r')
	finalsociallist=ff.readlines()
	ff.close()

	CountAvgSocialNum(finalsociallist)

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
	
	print neighborcount

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
	

	
	
def SocialDataAnalysis(socialList,ratingUserSet):

	socialUserSet=set()
	count=0
	# 重合的count
	itscount=0
	for line in socialList:
		data=line[:-1].split('\t')
		origUser=data[0]
		targetUser=data[1]
		socialUserSet.add(origUser)
		socialUserSet.add(targetUser)		
		count+=1
		if origUser in ratingUserSet and targetUser in ratingUserSet:
			itscount+=1
							
	# a=ratingUserSet & socialUserSet	
	print 'the social link num is %d ' % count
	print 'the user num is %d' % len(socialUserSet)
	print ' the intersection is %d , the link num is %d' % (len(socialUserSet & ratingUserSet ),itscount)
	
def RatingDataAnalysis(ratingList):
	userSet=set()
	itemSet=set()

	ratingScaleList=['1.0','2.0','3.0','4.0','5.0']
	raignCountList=[0,0,0,0,0]
	count=0
	for line in ratingList:
		count+=1
		data=line[:-2].split('\t')  #去掉末尾\n
		uid=data[0]
		iid=data[1]
		rating=data[2]
		userSet.add(uid)
		itemSet.add(iid)
		# 返回评分对应的index
		rcIndex=ratingScaleList.index(rating)
		raignCountList[rcIndex]+=1		
	print 'the usernum is %d, the item num is %d, the total rating num is %d \n' %(len(userSet),len(itemSet),count)
	print raignCountList
	return userSet


if __name__=='__main__':
	main()