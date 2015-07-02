import matplotlib.pyplot as plt
import sys
import numpy


def main():

	c1,n1 = loadData('cfulfTopNdiversity.txt')
	c2,n2= loadData('puretrustTopNdiversity.txt')
	c3,n3 = loadData('trustcfulfTopNdiversity.txt')
	c4,n4 = loadData('pbmimTopNdiversity.txt')
	c5,n5 = loadData('snmimTopNdiversity.txt')
	c6,n6 = loadData('cmimTopNdiversity.txt')
	
	fig = plt.figure(figsize=(8, 3), dpi=100,facecolor='w', edgecolor='k')
	plt.rc('axes', color_cycle=['#A0522D','#707070','#000000','#00B2EE', '#00EE00', '#FF0000',])
	plt.subplot(121)
	# plt.figure(figsize=(400,400))
	# ********************* plot coverage **********************************
	x = range(10,51,10)
	plt.plot(x,c1,linewidth=1.5,label='CF-ULF')
	plt.plot(x,c2,linewidth=1.5,label='PureTrust')
	plt.plot(x,c3,linewidth=1.5,label='Trust-CF-ULF')
	plt.plot(x,c4,linewidth=1.5,label='INCF-P')
	plt.plot(x,c5,linewidth=1.5,label='INCF-S')
	plt.plot(x,c6,linewidth=1.5,label='INCF-PS')
	
	legend = plt.legend(loc=0, shadow=True , fontsize ='xx-small')
	

	plt.xlabel('topN')
	plt.ylabel('coverage')
	# plt.show()s

	#********************* plot novelty **********************************
	plt.subplot(122)
	x = range(10,51,10)
	plt.plot(x,n1,linewidth=1.5,label='CF-ULF')
	plt.plot(x,n2,linewidth=1.5,label='PureTrust')
	plt.plot(x,n3,linewidth=1.5,label='Trust-CF-ULF')
	plt.plot(x,n4,linewidth=1.5,label='PMIM')
	plt.plot(x,n5,linewidth=1.5,label='SMIM')
	plt.plot(x,n6,linewidth=1.5,label='CMIM')
	
	legend = plt.legend(loc=0, shadow=True, fontsize ='xx-small' )
	

	plt.xlabel('topN')
	plt.ylabel('novelty')
	# plt.show()
	
	#********************* plot f1 **********************************

	

	
	
	fig.tight_layout()
	plt.show()
	
	
def loadData(fileName):
	codePath = sys.path[0]
	pathSet = codePath.split('\\')
	filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\flixster\\newfinalData\\'
	fileName = filePath + fileName
	
	coverage = []
	novelty = []
	
	f = open(fileName)
	dataSet = f.readlines()
	
	for line in dataSet:
		data = line[:-2].split('\t')
		data= map(float,data)
		coverage.append(data[0])
		novelty.append(data[1])

	return coverage,novelty
	
	
	
	
	
	
	
	
	
	
	
if __name__=='__main__':
	main()

