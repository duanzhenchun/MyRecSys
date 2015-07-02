#encoding:utf-8
import sys
import snap
import numpy as np
import random,math
import scipy.io as sio
import datetime
import os  
os.environ['MKL_NUM_THREADS'] = '10'


def main():

	starttime = datetime.datetime.now() 	
	
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath1=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\'  #f:\project\somproject
	workPath2=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\commondata\\'  #f:\project\somproject
	workPath3=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\svddata\\'  
	
	# set the parameters
	lambda_ = 0.1
	n_iterations = 100
	n_factors = 20
	epsilon_ = 0.001
	beta_ = 0.1
	rm = 1.0
	wm = 0.02
	
	svdModelName=workPath3+'svdModel_rm1_wm002_'+str(n_factors)+'.mat'
	
	
	# transfer node string to num      2131313 to 1
	# use the index of list to represent the node
		
	print 'load data...'	
	
	f=file(workPath2+'trainSet1.txt','r')	
	trainData=f.readlines()
	f.close()
	
	
	print 'built the graph...'
	filePath1 = workPath1+'commondata\\finalSocial.txt'
	totalNodeList = []
	G1 = snap.TUNGraph.New()
	for line in open(filePath1):
		if line=='':
			break	
		linkPair=line[:-1].split('\t')
		node1=int(linkPair[0])
		node2=int(linkPair[1])
		if node1 not in totalNodeList:
			totalNodeList.append(node1)
		if node2 not in totalNodeList:
			totalNodeList.append(node2)
			
		node1MapNum=totalNodeList.index(node1)
		node2MapNum=totalNodeList.index(node2)
		
		if not G1.IsNode(node1MapNum):
			G1.AddNode(node1MapNum)
		if not G1.IsNode(node2MapNum):
			G1.AddNode(node2MapNum)
		G1.AddEdge(node1MapNum,node2MapNum)
		
	userNum=len(set(totalNodeList))
	print 'graph complete...'
	
	
	print 'get rating data...'		
	trainSet=list()
	uniqueItemData=set()
	for line in trainData:
		# **************注意这个地方处理几个字符*****************
		line=line[:-2].split('\t')
		trainSet.append([float(line[0]),float(line[1]),float(line[2])])
		uniqueItemData.add(int(line[1]))
	trainSet=np.array(trainSet)
	uniqueItemData=list(uniqueItemData)
	uniqueItemData.sort()	
	itemNum=len(set(trainSet[:,1]))

	R=np.zeros((userNum,itemNum))
	step=0
	num20=int(len(trainData)*0.2)
	for line in trainData:
		step+=1
		if step%num20==0:
			print 'haha 20%...'
		line=line[:-2].split('\t')
		user=int(line[0])
		item=int(line[1])
		rating=float(line[2])
		uid=totalNodeList.index(user)
		iid=uniqueItemData.index(item)
		R[uid,iid]=rating
	
	
	print 'get social data...'
	print G1.GetEdges()
	S=np.zeros((userNum,userNum))
	for i in range(userNum):
		currentNode=i
		neighbourSet=G1.GetNI(currentNode)
		connNodeNum=neighbourSet.GetDeg()
		for j in range(connNodeNum):
			neighBourNode=neighbourSet.GetNbrNId(j)
			S[currentNode,neighBourNode]=1
			S[neighBourNode,currentNode]=1
		
	Q,P=ALSTrain(R,S,n_factors,n_iterations,lambda_,epsilon_,beta_,rm,wm)
	
	sio.savemat(svdModelName, {'Q': Q,'P': P,'rm': rm,'totalNodeList':totalNodeList,})  
	print 'finished...'
	
	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds  


def ALSTrain(R,S,n_factors,n_iterations,lambda_,epsilon_,beta_,rm,wm):
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
		Qold = Q
		IminusSmtpQold = np.dot((np.eye(m)-S), Qold)     # (I - S) * Qold
		IminusSt = np.eye(m)-S.T   # I - S.T
		for u, Wu in enumerate(W):
			iList = [i for i in range(n) if R[u,i] > 0]
			Q[u] = np.linalg.solve( uFixedMatrix - wm * np.dot(P[iList].T, P[iList])
					+ np.dot(P[iList].T, np.dot(np.diag(Wu[iList]), P[iList])) + (lambda_ + epsilon_) * np.eye(n_factors),
					(np.dot( (R[u,iList] - rm), np.dot(np.diag(Wu[iList]),P[iList])) 
					+ np.dot(beta_ * IminusSt[u], IminusSmtpQold)
					+ epsilon_ * Qold[u]).T
					).T
			
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