# -*- coding:utf-8 -*-  
import snap
import sys
import datetime
import numpy

'''
 work for socialMF 
just return the direct social friend of the target user
'''

def	main():
	starttime = datetime.datetime.now() 	

	version = '1'
	
	print 'load the nodes ...'
	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\epinions\\commondata\\'  #f:\project\somproject
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
	
	
	# BFS遍历并取得trust值
	print 'start get trust...'
	writer=open(workPath+'trustListForSocialMF'+version+'.txt','w')
	neighBourNum=200
	for i in range(len(coreNodeList)):
		mod20=len(coreNodeList)/5
		if i%mod20==0:
			print '20%...'
		
		fNode=coreNodeList[i]
		visitPath=specialBFS(fNode,myGraph,neighBourNum,coreNodeList,totalNodeList,nodeMapNumDict)
		visitPath,trustList = GetTrustList(fNode,myGraph,visitPath,totalNodeList,nodeMapNumDict)
		
		for j in range(len(visitPath)):
			dstNode=visitPath[j]
			trustValue=trustList[j]
			
			dataline=str(fNode)+'\t'+str(dstNode)+'\t'+str(trustValue)+'\n'
			writer.write(dataline)
			# print ' the dst node is %d ,the trust is %f' %(visitPath[i],trustList[i])
	
	writer.close()

	print 'finished'	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds 


	
def GetTrustList(fSourceNode,graph,visitPath,totalNodeList,nodeMapNumDict):
	# trustList=[0] * len(visitPath)
	# tSourceIndex=totalNodeList.index(fSourceNode)
	trustList = []
	newVisitPath = []
	tSourceIndex=nodeMapNumDict[fSourceNode]
	
	# tVisitPathIndex=[totalNodeList.index(node) for node in visitPath]
	tVisitPathIndex=[nodeMapNumDict[node] for node in visitPath]
	
	for i in range(len(visitPath)):
		node = visitPath[i]
		tempDstNodeIndex = nodeMapNumDict[node]
		dist=snap.GetShortPath(graph,tSourceIndex,tempDstNodeIndex)
		if dist ==1:
			newVisitPath.append(node)
			trustList.append('1')
	
	return newVisitPath,trustList

	
# only include the finalUserID to the path	
# return the original node id in totalNodeList
def specialBFS(fNode,graph,neighBourNum,coreNodeList,totalNodeList,nodeMapNumDict):
	
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
		for i in range(connNodeNum):
			tempNodeIndex=neighbourSet.GetNbrNId(i)
			if visitList[tempNodeIndex]!=1:
				visitList[tempNodeIndex]=1
				queueList.append(tempNodeIndex)
				# map to orig node
				origNode=totalNodeList[tempNodeIndex]
				if origNode in coreNodeList:
					visitPath.append(origNode)
					if len(visitPath)==neighBourNum:
						return visitPath
				
	return visitPath
	

if __name__=='__main__':
	import profile
	profile.run("main()")
	
	