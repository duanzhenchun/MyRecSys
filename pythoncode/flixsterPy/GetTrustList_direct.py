# -*- coding:utf-8 -*-  
import snap
import sys
import datetime
import numpy

''' 
改进版的gettrustlist
在进行BFS选择时，依据点与目标用户之间共同打分的个数进行排序 降序排列
每次选择都是
'''

def	main(version):
	starttime = datetime.datetime.now() 	
		
	print 'load the nodes ...'
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\flixster\\commondata\\'  #f:\project\somproject
	filePath1=workPath+'finalSocial'+version+'.txt'
	totalNodeList=[]
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
			
	filePath2=workPath+'coreUserID'+version+'.txt'
	coreNodeList=[]
	for line in open(filePath2):
		if line=='':
			break		
		nodeStr=line[:-1]
		node=int(nodeStr)	
		coreNodeList.append(node)		

			
	print 'load the connected component  ...'
	FIn = snap.TFIn(workPath+'finalSocial'+version+'.graph')
	myGraph = snap.TUNGraph.Load(FIn)
	
	# build a dict to store the no. of node in totalNodeList
	nodeMapNumDict = dict()
	for node in totalNodeList:
		mapNum=totalNodeList.index(node)
		nodeMapNumDict[node] = mapNum
	
	print 'get the user item map dict ...'
	filePath3 = workPath+'trainSet'+version+'.txt'
	f = file(filePath3,'r')
	trainList = f.readlines()
	f.close()
	userItemMapDict=GetUserItemMapDict(trainList, nodeMapNumDict)
		
	# BFS遍历并取得trust值
	print 'start get trust...'
	writer=open(workPath+'trust200_direct'+version+'.txt','w')
	neighBourNum=200
	for i in range(len(coreNodeList)):
		mod20=len(coreNodeList)/5
		if i%mod20==0:
			print '20%...'
		
		fNode=coreNodeList[i]
		visitPath=SpecialBFS(fNode,myGraph,neighBourNum,coreNodeList,totalNodeList,nodeMapNumDict,userItemMapDict)
		trustList=GetTrustList(fNode,myGraph,visitPath,totalNodeList,nodeMapNumDict)
		
		for j in range(neighBourNum):
			dstNode=visitPath[j]
			trustValue=trustList[j]
			
			dataline=str(fNode)+'\t'+str(dstNode)+'\t'+str(trustValue)+'\n'
			writer.write(dataline)
	
	writer.close()

	
	
	print 'finished'	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds 


	
def GetTrustList(fSourceNode,graph,visitPath,totalNodeList,nodeMapNumDict):
	trustList=[0] * len(visitPath)
	# tSourceIndex=totalNodeList.index(fSourceNode)
	tSourceIndex=nodeMapNumDict[fSourceNode]
	
	# tVisitPathIndex=[totalNodeList.index(node) for node in visitPath]
	tVisitPathIndex=[nodeMapNumDict[node] for node in visitPath]
	
	for i in range(len(tVisitPathIndex)):
		tempDstNodeIndex=tVisitPathIndex[i]
		dist=snap.GetShortPath(graph,tSourceIndex,tempDstNodeIndex)
		trustList[i]=1.0/dist
	
	return trustList

	
# only include the finalUserID to the path	
# return the original node id in totalNodeList
def SpecialBFS(fNode,graph,neighBourNum,coreNodeList,totalNodeList,nodeMapNumDict,userItemMapDict):
	
	# tSourceNodeIndex=totalNodeList.index(fNode)
	tSourceNodeIndex=nodeMapNumDict[fNode]
	totalNodesNum=graph.GetNodes()
	# record whether been visited
	visitList=[0]* totalNodesNum
	visitList[tSourceNodeIndex]=1
	# record the visited sequence 
	visitPath=[]
	# store the bfs node,first in first out
	queueList=[]
	queueList.append(tSourceNodeIndex)
	
	while len(queueList)>0:
		currentNodeIndex=queueList[0]
		del queueList[0]
		neighbourSet=graph.GetNI(currentNodeIndex)
		connNodeNum=neighbourSet.GetDeg()
		neighbourList = TuneOrderByCommonRating(tSourceNodeIndex,neighbourSet,userItemMapDict,nodeMapNumDict,totalNodeList,coreNodeList)
		for i in range(connNodeNum):
			tempNodeIndex=neighbourList[i]
			if visitList[tempNodeIndex]!=1:
				visitList[tempNodeIndex]=1
				queueList.append(tempNodeIndex)
				# map to orig node
				origNode=totalNodeList[tempNodeIndex]
				if origNode in coreNodeList:
					visitPath.append(origNode)
					if len(visitPath) == neighBourNum:
						return visitPath
				
	return visitPath
	
def TuneOrderByCommonRating(srcNodeIdx,neighbourSet,userItemMapDict,nodeMapNumDict,totalNodeList,coreNodeList):
	''' 根据 原始结点 与 邻近结点 之间 共同打分个数 的多少调整顺序 '''
	''' 共同打分个数最多的放最前面，若都没有共同打分，则算了 '''
	
	neighbourList = []
	# convert neighbourSet to neighbourList
	connNodeNum = neighbourSet.GetDeg()
	for i in range(connNodeNum):
		neighbourList.append(neighbourSet.GetNbrNId(i))
	
	if srcNodeIdx not in userItemMapDict.keys():
		# print 'no no ~'
		return neighbourList
	else:	
		srcNodeItemList = userItemMapDict[srcNodeIdx]
		ratingNodeIdxItemNumDict = dict()  # nodeIdx - common item num
		elseNodeIdxList = list()
		for i in range(connNodeNum):
			tempNodeIndex = neighbourList[i]
			if tempNodeIndex in userItemMapDict.keys():
				tempNodeItemList = userItemMapDict[tempNodeIndex]
				commonItemNum = len(set(tempNodeItemList) & set(srcNodeItemList))
				ratingNodeIdxItemNumDict[tempNodeIndex] = commonItemNum
			else:
				elseNodeIdxList.append(tempNodeIndex)
		
		# sort by common item num
		newdictList = sorted(ratingNodeIdxItemNumDict.iteritems(), key = lambda a:a[1],reverse = True)
		tuneNodeIdxList = []
		for line in newdictList:
			tuneNodeIdxList.append(line[0])
		tuneNodeIdxList.extend(elseNodeIdxList)

		return tuneNodeIdxList
		
def GetUserItemMapDict(trainList, nodeMapNumDict):	
	''' map the user and the item set'''
	userItemMapDict = dict()
	for line in trainList:
		data=line.split('\t')
		user = int(data[0])
		item = int(data[1])
		uid = nodeMapNumDict[user]
		userItemMapDict.setdefault(uid,list()).append(item)
	
	return userItemMapDict

if __name__=='__main__':
	# import profile
	# profile.run("main()")
	main()
	
	