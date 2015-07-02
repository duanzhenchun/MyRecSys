#encoding:utf-8
import sys
import numpy as np
import random,math
import scipy.io as sio
import datetime

def main():
	starttime = datetime.datetime.now() 	
	
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\commondata\\'  #f:\project\somproject
	workPath2=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\svddata\\'  
	
	f=file(workPath+'trainSet1.txt','r')	
	trainData=f.readlines()
	f.close()
	
	ff=file(workPath+'testSet1.txt','r')
	testData=ff.readlines()
	ff.close()
	
	learnRate=0.01
	regularization=0.05
	iterStep=50
	factorNum=50
	svdModelName=workPath2+'svdModel1_'+str(factorNum)+'.mat'
	
	
	trainSet=list()
	uniqueUserData=set()
	uniqueItemData=set()
	for line in trainData:
		# **************注意这个地方处理几个字符*****************
		line=line[:-2].split('\t')
		trainSet.append([float(line[0]),float(line[1]),float(line[2])])
		uniqueUserData.add(int(line[0]))
		uniqueItemData.add(int(line[1]))
	trainSet=np.array(trainSet)
	
	testSet=list()
	for line in testData:
		# **************注意这个地方处理几个字符*****************
		line=line[:-2].split('\t')
		testSet.append([float(line[0]),float(line[1]),float(line[2])])
	testSet=np.array(testSet)
	
	uniqueUserData=list(uniqueUserData)
	uniqueItemData=list(uniqueItemData)
	uniqueUserData.sort()
	uniqueItemData.sort()

	# print repr(int(trainSet[1,1]))
	
	userNum=len(set(trainSet[:,0]))
	itemNum=len(set(trainSet[:,1]))
	avgRating=sum(trainSet[:,2])/len(trainData)
	
	bu,bi,pu,qi=SVDTrain(avgRating,userNum,itemNum,learnRate,regularization,iterStep,factorNum,uniqueUserData,uniqueItemData,trainSet,testSet)
	
	sio.savemat(svdModelName, {'bu': bu,'bi': bi,'pu': pu,'qi':qi,'avgRating':avgRating,'iterStep':iterStep,'factorNum':factorNum})  
	
	print 'finished...'
	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds  
	
def SVDTrain(avgRating,userNum,itemNum,learnRate,regularization,iterStep,factorNum,uniqueUserData,uniqueItemData,trainSet,testSet):
	
	bi = [0.0 for i in range(itemNum)]
	bu = [0.0 for i in range(userNum)]
	temp = math.sqrt(factorNum)
	qi = [[(0.1 * random.random() / temp) for j in range(factorNum)] for i in range(itemNum)]	
	pu = [[(0.1 * random.random() / temp)  for j in range(factorNum)] for i in range(userNum)]
	
	pu=np.array(pu)
	qi=np.array(qi)
	
	print("initialization end\nstart training\n")
	
	preRmse = 1000000.0
	for i in range(iterStep):
		totalCount=trainSet.shape[0]
		for j in range(totalCount):
			
			randIndex=random.randint(0,totalCount-1)
			user=int(trainSet[randIndex,0])
			item=int(trainSet[randIndex,1])
			rating=float(trainSet[randIndex,2])
			uid=uniqueUserData.index(user)
			iid=uniqueItemData.index(item)
			
			prediction=avgRating+bu[uid]+bi[iid]+InnerProduct(pu[uid], qi[iid])
				
			if prediction < 1:
				prediction = 1
			elif prediction > 5:
				prediction = 5
			
			eui = rating - prediction
		
			#update parameters
			bu[uid] += learnRate * (eui - regularization * bu[uid])
			bi[iid] += learnRate * (eui - regularization * bi[iid])	
			
			# print type(uid)
			# print pu[uid,:]
			# print -eui*qi[iid,:]
			# print regularization*pu[uid,:]
			
			temp=pu
			pu[uid,:]=pu[uid,:]-learnRate*(-eui*qi[iid,:]+regularization*pu[uid,:])
			qi[iid,:]=qi[iid,:]-learnRate*(-eui*temp[uid,:]+regularization*qi[iid,:])
			
			# for k in range(factorNum):
				# temp = pu[uid][k]	#attention here, must save the value of pu before updating
				# pu[uid][k] += learnRate * (eui * qi[iid][k] - regularization * pu[uid][k])
				# qi[iid][k] += learnRate * (eui * temp - regularization * qi[iid][k])
				
				
		#learnRate *= 0.9
		curRmse = Validate(testSet, avgRating, bu, bi, pu, qi,uniqueUserData,uniqueItemData)
		print("test_RMSE in step %d: %f" %(i, curRmse))
		if curRmse >= preRmse:
			break
		else:
			preRmse = curRmse
					
	print("model generation over")
	return bu,bi,pu,qi
	
	
#validate the model
def Validate(testSet, avgRating, bu, bi, pu, qi,uniqueUserData,uniqueItemData):
	cnt = 0
	rmse = 0.0
	totalCount=testSet.shape[0]
	
	# userList=testSet[:,0]
	# itemList=testSet[:,1]
	# ratingList=testSet[:,2]
	# uidList=[0]*totalCount
	# iidList=[0]*totalCount
	# bu=np.array(bu)
	# bi=np.array(bi)
	# for i in range(totalCount):
		# user=userList[i]
		# item=itemList[i]
		# uidList[i]=uniqueUserData.index(user)
		# iidList[i]=uniqueItemData.index(item)
	
	# predictList=avgRating+bu[uidList]+bi[iidList]+sum(pu[uidList,:]*qi[iidList,:])
	# dist=ratingList-predictList
	# rmse=InnerProduct(dist,dist)/totalCount
	# rmse=math.sqrt(rmse)
	
	
	for i in range(totalCount):
		cnt += 1
		user=int(testSet[i,0])
		item=int(testSet[i,1])
		rating=float(testSet[i,2])
		uid=uniqueUserData.index(user)
		iid=uniqueItemData.index(item)
		predict = avgRating+bu[uid]+bi[iid]+InnerProduct(pu[uid], qi[iid])
			
		rmse += (rating - predict) * (rating - predict)
		
	rmse=math.sqrt(rmse/cnt)
	return rmse

	
def sumByCol(dataArray):
	colNum=dataArray.shape[1]
	sumcolList=[0]*colNum
	for i in range(colNum):
		colData=dataArray[:,i]
		sumcol=sum(colData)
		sumcolList[i]=sumcol
	
	return array(sumcolList)
	
	
def InnerProduct(v1, v2):
	result = 0
	for i in range(len(v1)):
		result += v1[i] * v2[i]
		
	return result



if __name__ == '__main__':
	main()
	