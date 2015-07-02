import sys
import snap
import datetime

starttime = datetime.datetime.now() 	



codePath=sys.path[0]
filePath=codePath+'\\'+'finalSocial.txt'

# transfer node string to num      2131313 to 1
# use the index of list to represent the node

nodeList=[]
for line in open(filePath):
	if line=='':
		break	
	linkPair=line[:-1].split('\t')
	node1=int(linkPair[0])
	node2=int(linkPair[1])
	if node1 not in nodeList:
		nodeList.append(node1)
	if node2 not in nodeList:
		nodeList.append(node2)


G1 = snap.TUNGraph.New()

for line in open(filePath):
	if line=='':
		break		
	linkPair=line[:-1].split('\t')
	node1=int(linkPair[0])
	node2=int(linkPair[1])
	
	node1MapNum=nodeList.index(node1)
	node2MapNum=nodeList.index(node2)
	
	if not G1.IsNode(node1MapNum):
		G1.AddNode(node1MapNum)
	if not G1.IsNode(node2MapNum):
		G1.AddNode(node2MapNum)
		
	G1.AddEdge(node1MapNum,node2MapNum)
	
	
	# print line
	# print '%d --> %d' % (node1,node2)

	
# for EI in G1.Edges():
	# print "edge (%d, %d)" % (EI.GetSrcNId(), EI.GetDstNId())
	

	
# get the connected component...
MxWcc = snap.GetMxWcc(G1)
print 'the connected component node num is  %d ' % MxWcc.GetNodes()

	
FOut = snap.TFOut(codePath+"\\finalSocial.graph")
MxWcc.Save(FOut)
FOut.Flush()	






print 'finished'	
endtime = datetime.datetime.now()   
print 'passed time is %d s' % (endtime - starttime).seconds 
