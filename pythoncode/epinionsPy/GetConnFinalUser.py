# -*- coding:utf-8 -*-  
import sys
import datetime
import snap

# 通过获取最大连通子图来去除孤立的结点
# 获得 coreUser 和 finalSocial
version = '1'

def main():
	starttime = datetime.datetime.now() 	

	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\epinions\\'  #f:\project\somproject

	# transfer node string to num      2131313 to 1
	# use the index of list to represent the node
	
	print 'use social data to build the graph... '
	filePath1=workPath+'commondata\\rawSocial'+version+'.txt'
	totalNodeList=[]
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
		
	
	print 'get the max connected component...'
	MxWcc = snap.GetMxWcc(G1)
	print 'the max  connected component node num is  %d ' % MxWcc.GetNodes()
	
	print 'get  user id   in  the  max connected component... '
	
	
	writer2=open(workPath+'commondata\\coreUserID'+version+'.txt','w')
	filePath2=workPath+'commondata\\rawCoreUserID'+version+'.txt'
	coreUserList=[]
	for line in open(filePath2):
		if line=='':
			break		
		nodeStr=line[:-1]
		node=int(nodeStr)
		nodeMapNum=totalNodeList.index(node)
		if MxWcc.IsNode(nodeMapNum):
			coreUserList.append(node)
			nodeLine=str(node)+'\n'
			writer2.write(nodeLine)
	writer2.close()
			
	print 'the core user num is %d' %len(coreUserList)

	
	print 'finished'	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds 

	
if __name__=='__main__':
	import profile
	profile.run("main()")
	# main()





