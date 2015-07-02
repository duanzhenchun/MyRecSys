import snap
import sys
import datetime

starttime = datetime.datetime.now() 	


codePath=sys.path[0]

print  'load the original data, transfer it ...'
filePath=codePath+'\\'+'finalSocial.txt'
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
		
		

print 'load the connected component  ...'
FIn = snap.TFIn(codePath+"\\finalSocial.graph")
G1 = snap.TUNGraph.Load(FIn)



# for EI in G1.Edges():
	# print "edge (%d, %d)" % (EI.GetSrcNId(), EI.GetDstNId())

print ' write the community data to txt ...'

CmtyV = snap.TCnComV()
modularity = snap.CommunityCNM(G1, CmtyV)

writer=open(codePath+'\\'+'communityNodes.txt','w')

count=0
communityNO=0

for Cmty in CmtyV:
	communityNO+=1
	for node in Cmty:
		orgNum=nodeList[node]  # node is the index, use it to get the original node num
		dataline=str(communityNO)+'\t'+str(orgNum)+'\n'
		writer.write(dataline)
		
writer.close()		   		
		
print 'the community num is %d ' % len(CmtyV)
print "The modularity of the network is %f" % modularity



print 'finished'	
endtime = datetime.datetime.now()   
print 'passed time is %d s' % (endtime - starttime).seconds 