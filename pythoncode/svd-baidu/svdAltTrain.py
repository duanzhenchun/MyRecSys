#encoding:utf-8
import sys
import numpy as np
import random,math
import scipy.io as sio
import datetime
import os  
os.environ['MKL_NUM_THREADS'] = '5'


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
	
	lambda_=0.1
	n_iterations = 100
	n_factors = 50
	rm=1.0
	wm=0.02
	
	svdModelName=workPath2+'svdModel_rm1_wm002_'+str(n_factors)+'.mat'
	
	uniqueUserData=set()
	uniqueItemData=set()
	
	trainSet=list()
	for line in trainData:
		# **************注意这个地方处理几个字符*****************
		line=line[:-2].split('\t')
		trainSet.append([float(line[0]),float(line[1]),float(line[2])])
		uniqueItemData.add(int(line[1]))
	trainSet=np.array(trainSet)
	
	testSet=list()
	for line in testData:
	# **************注意这个地方处理几个字符*****************
		line=line[:-2].split('\t')
		testSet.append([float(line[0]),float(line[1]),float(line[2])])
		uniqueUserData.add(int(line[0]))
	testSet=np.array(testSet)
	
	
	uniqueUserData=list(uniqueUserData)
	uniqueItemData=list(uniqueItemData)
	uniqueUserData.sort()
	uniqueItemData.sort()

	userNum=len(set(testSet[:,0]))  # user num 来自于testSet
	itemNum=len(set(trainSet[:,1])) #　item num 来自于trainSet

	R=np.zeros((userNum,itemNum))
	for line in trainData:
		line=line[:-2].split('\t')
		user=int(line[0])
		item=int(line[1])
		rating=float(line[2])
		uid=uniqueUserData.index(user)
		iid=uniqueItemData.index(item)
		R[uid,iid]=rating
		
	Q,P=ALSTrain(R,n_factors,n_iterations,lambda_,rm,wm)
	
	sio.savemat(svdModelName, {'Q': Q,'P': P,'rm': rm,})  
	print 'finished...'
	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds  


def ALSTrain(R,n_factors,n_iterations,lambda_,rm,wm):
	m,n=R.shape
	Q =  5*np.random.rand(m, n_factors)   # m x f   user factor matrix
	P =  5*np.random.rand(n, n_factors)   # n x f   item factor matrix
	W = R>0
	W[W == True] = 1
	W[W == False] = wm
	# To be consistent with our R matrix
	W = W.astype(np.float64, copy=False)
	weighted_errors=[]
	print("initialization end\n start training\n")
	
	preRmse = 10000000.0
	for iter in range(n_iterations):
		
		uFixedMatrix = wm * np.dot(P.T,P)
		for u, Wu in enumerate(W):
			iList = [i for i in range(n) if R[u,i] > 0]
			Q[u] = np.linalg.solve(uFixedMatrix - wm * np.dot(P[iList].T, P[iList])
					+ np.dot(P[iList].T, np.dot(np.diag(Wu[iList]), P[iList])) + lambda_ * np.eye(n_factors),
					np.dot(P[iList].T, np.dot(np.diag(Wu[iList]), (R[u,iList] - rm).T))).T
		
		
		iFixedMatrix = wm * np.dot(Q.T, Q)
		for i, Wi in enumerate(W.T):
			uList = [u for u in range(m) if R[u,i] > 0]
			P[i] = np.linalg.solve( iFixedMatrix - wm * np.dot(Q[uList].T, Q[uList]) 
					+ np.dot(Q[uList].T, np.dot(np.diag(Wi[uList]), Q[uList]) ) + lambda_ * np.eye(n_factors),
					np.dot(Q[uList].T, np.dot(np.diag(Wi[uList]), (R[uList,i] - rm)))).T
			
				
		weighted_errors.append(get_error(R, Q, P, W, rm))
		curRmse = weighted_errors[iter]
		if curRmse >= preRmse:
			break
		else:
			preRmse = curRmse
		print('{}th iteration is completed'.format(iter+1))
		print 'error is %f' % weighted_errors[iter]
		
	print("model generation over")
	return Q,P
	
def get_error(R, Q, P, W, rm):
	return np.sqrt(np.sum((W * (R - rm - np.dot(Q, P.T)))**2))



if __name__ == '__main__':
	main()