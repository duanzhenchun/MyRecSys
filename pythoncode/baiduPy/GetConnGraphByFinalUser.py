# -*- coding:utf-8 -*-  

import sys
import snap
import datetime

# 这断代码不可少，因为图会重新排序，结点的序号也变了
# 在获取finalUserID之后，获取整个的连通的子图，为下阶段提供图
def main():
	starttime = datetime.datetime.now() 	

	codePath=sys.path[0]
	s=codePath.split('\\')
	workPath=s[0]+'\\'+s[1]+'\\'+s[2]+'\\data\\baidu\\commondata\\'  #f:\project\somproject
	filePath1=workPath+'finalSocial.txt'

	# transfer node string to num      2131313 to 1
	# use the index of list to represent the node

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
	print 'the max connected component node num is  %d ' % MxWcc.GetNodes()

	print MxWcc.GetEdges()
	# filePath2=workPath+'finalUserID.txt'
	# finalNodeList=[]
	# for line in open(filePath2):
		# if line=='':
			# break		
		# nodeStr=line[:-1]
		# node=int(nodeStr)	
		# nodeMapNum=totalNodeList.index(node)
		
		# if MxWcc.IsNode(nodeMapNum):
			# finalNodeList.append(node)
		
	# print 'the final user num is %d' %len(finalNodeList)


		
	FOut = snap.TFOut(workPath+"finalSocial.graph")
	MxWcc.Save(FOut)
	FOut.Flush()	


	print 'finished'	
	endtime = datetime.datetime.now()   
	print 'passed time is %d s' % (endtime - starttime).seconds 
