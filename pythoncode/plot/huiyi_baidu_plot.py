import matplotlib.pyplot as plt
import sys
import numpy


def main():

	p1,r1,f1 = loadData('itemCF.txt')
	p2,r2,f2 = loadData('userCF.txt')
	p3,r3,f3 = loadData('pbmim.txt')

	
	fig = plt.figure(figsize=(11, 3), dpi=100,facecolor='w', edgecolor='k')
	plt.rc('axes', color_cycle=['#3399CC',(0.0,0.5,0.0),(0.8,0.0,0.0), ])
	plt.subplot(131)
	# plt.figure(figsize=(400,400))
	# ********************* plot precision **********************************
	x = range(10,101,10)
	plt.plot(x,p1,linewidth=1.5,label='ItemCF',linestyle= '-.')
	plt.plot(x,p2,linewidth=1.5,label='UserCF',linestyle= '--')
	plt.plot(x,p3,linewidth=1.5,label='MCF',linestyle = '-')
	
	legend = plt.legend(loc=0, shadow=True , fontsize ='x-small')
	

	plt.xlabel('topN')
	plt.ylabel('precision')
	# plt.show()s

	#********************* plot recall **********************************
	plt.subplot(132)
	x = range(10,101,10)
	plt.plot(x,r1,linewidth=1.5,label='ItemCF',linestyle= '-.')
	plt.plot(x,r2,linewidth=1.5,label='UserCF',linestyle= '--')
	plt.plot(x,r3,linewidth=1.5,label='MCF',linestyle = '-')
	
	legend = plt.legend(loc=0, shadow=True, fontsize ='x-small' )
	

	plt.xlabel('topN')
	plt.ylabel('recall')
	# plt.show()
	
	#********************* plot f1 **********************************
	plt.subplot(133)
	x = range(10,101,10)
	plt.plot(x,f1,linewidth=1.5,label='ItemCF',linestyle= '-.')
	plt.plot(x,f2,linewidth=1.5,label='UserCF',linestyle= '--')
	plt.plot(x,f3,linewidth=1.5,label='MCF',linestyle = '-')
	
	legend = plt.legend(loc=0, shadow=True , fontsize ='x-small' )
	

	plt.xlabel('topN')
	plt.ylabel('f1')
	
	
	fig.tight_layout()
	plt.show()
	
	
def loadData(fileName):
	codePath = sys.path[0]
	pathSet = codePath.split('\\')
	filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\baidu\\huiyifinalData\\'
	fileName = filePath + fileName
	
	precision = []
	recall = []
	f1 = []
	
	f = open(fileName)
	dataSet = f.readlines()
	
	for line in dataSet:
		data = line[:-2].split('\t')
		data= map(float,data)
		precision.append(data[0])
		recall.append(data[1])
		f1.append(data[2])
	
	return precision,recall,f1
	
	
	
	
	
	
	
	
	
	
	
if __name__=='__main__':
	main()

