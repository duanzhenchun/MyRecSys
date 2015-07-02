import matplotlib.pyplot as plt
import sys
import numpy


def main():

	p1,r1,f1 = loadData('cfulfTopN.txt')
	p2,r2,f2 = loadData('pureTrustTopN.txt')
	p3,r3,f3 = loadData('trustcfulfTopN.txt')
	p4,r4,f4 = loadData('pbmimTopN.txt')
	p5,r5,f5 = loadData('scmimTopN.txt')
	p6,r6,f6 = loadData('cmimTopN.txt')
	
	fig = plt.figure(figsize=(11, 3), dpi=100,facecolor='w', edgecolor='k')
	plt.rc('axes', color_cycle=['#A0522D','#707070','#000000','#00B2EE', '#00EE00', '#FF0000',])
	plt.subplot(131)
	# plt.figure(figsize=(400,400))
	# ********************* plot precision **********************************
	x = range(10,101,10)
	plt.plot(x,p1,linewidth=1.5,label='CF-ULF')
	plt.plot(x,p2,linewidth=1.5,label='PureTrust')
	plt.plot(x,p3,linewidth=1.5,label='Trust-CF-ULF')
	plt.plot(x,p4,linewidth=1.5,label='PMIM')
	plt.plot(x,p5,linewidth=1.5,label='SMIM')
	plt.plot(x,p6,linewidth=1.5,label='CMIM')
	
	legend = plt.legend(loc=0, shadow=True , fontsize ='xx-small')
	
	plt.title('precision VS topN')
	plt.xlabel('topN')
	plt.ylabel('precision')
	# plt.show()s

	#********************* plot recall **********************************
	plt.subplot(132)
	x = range(10,101,10)
	plt.plot(x,r1,linewidth=1.5,label='CF-ULF')
	plt.plot(x,r2,linewidth=1.5,label='PureTrust')
	plt.plot(x,r3,linewidth=1.5,label='Trust-CF-ULF')
	plt.plot(x,r4,linewidth=1.5,label='PMIM')
	plt.plot(x,r5,linewidth=1.5,label='SMIM')
	plt.plot(x,r6,linewidth=1.5,label='CMIM')
	
	legend = plt.legend(loc=0, shadow=True, fontsize ='xx-small' )
	
	plt.title('recall VS topN')
	plt.xlabel('topN')
	plt.ylabel('recall')
	# plt.show()
	
	#********************* plot f1 **********************************
	plt.subplot(133)
	x = range(10,101,10)
	plt.plot(x,f1,linewidth=1.5,label='CF-ULF')
	plt.plot(x,f2,linewidth=1.5,label='PureTrust')
	plt.plot(x,f3,linewidth=1.5,label='Trust-CF-ULF')
	plt.plot(x,f4,linewidth=1.5,label='PMIM')
	plt.plot(x,f5,linewidth=1.5,label='SMIM')
	plt.plot(x,f6,linewidth=1.5,label='CMIM')
	
	legend = plt.legend(loc=3, shadow=True , fontsize ='xx-small' )
	
	plt.title('f1 VS topN')
	plt.xlabel('topN')
	plt.ylabel('f1')
	
	
	fig.tight_layout()
	plt.show()
	
	
def loadData(fileName):
	codePath = sys.path[0]
	pathSet = codePath.split('\\')
	filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\baidu\\finalData\\'
	fileName = filePath + fileName
	
	precision = []
	recall = []
	f1 = []
	
	f = open(fileName)
	dataSet = f.readlines()
	
	for line in dataSet:
		data = line[:-2].split(' \t')
		data= map(float,data)
		precision.append(data[0])
		recall.append(data[1])
		f1.append(data[2])
	
	return precision,recall,f1
	
	
	
	
	
	
	
	
	
	
	
if __name__=='__main__':
	main()

