#encoding:utf-8
import sys
 

# 统计用户数，item数和评分分布情况

def main():
	
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\epinions\\'  #f:\project\somproject
	f=file(workPath+'ratings_data.txt','r')
	ratingList=f.readlines()
	f.close()
	ff=file(workPath+'trust_data.txt','r')
	# ff=file(workPath+'commondata\\finalsocial.txt','r')
	socialList=ff.readlines()
	ff.close()
			
	ratingUserSet=RatingDataAnalysis(ratingList)	
	SocialDataAnalysis(socialList,ratingUserSet)


	
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

	ratingScaleList=['1','2','3','4','5']
	raignCountList=[0,0,0,0,0]
	count=0
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
	print raignCountList
	return userSet


if __name__=='__main__':
	main()