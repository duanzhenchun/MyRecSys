import matplotlib.pyplot as plt
import sys
import numpy


def main():


	cf1,n1 = loadData_diversity_flixster('cfulfTopNdiversity.txt')
	cf2,n2= loadData_diversity_flixster('puretrustTopNdiversity.txt')
	cf3,n3 = loadData_diversity_flixster('trustcfulfTopNdiversity.txt')
	cf4,n4 = loadData_diversity_flixster('pbmimTopNdiversity.txt')
	cf5,n5 = loadData_diversity_flixster('snmimTopNdiversity.txt')
	cf6,n6 = loadData_diversity_flixster('cmimTopNdiversity.txt')
    
    
	cb1,n1 = loadData_diversity_baidu('cfulfTopNdiversity.txt')
	cb2,n2= loadData_diversity_baidu('puretrustTopNdiversity.txt')
	cb3,n3 = loadData_diversity_baidu('trustcfulfTopNdiversity.txt')
	cb4,n4 = loadData_diversity_baidu('pbmimTopNdiversity.txt')
	cb5,n5 = loadData_diversity_baidu('snmimTopNdiversity.txt')
	cb6,n6 = loadData_diversity_baidu('cmimTopNdiversity.txt')
    
    
    
   
	# fig = plt.figure(figsize=(8, 3), dpi=100,facecolor='w', edgecolor='k')
	plt.rc('axes', color_cycle=['#A0522D','#707070','#000000','#00B2EE', '#00EE00', '#FF0000',])
	# plt.subplot(121)
	# plt.figure(figsize=(400,400))
	# ********************* plot precision **********************************
	x = range(10,51,10)
	plt.plot(x,cf1,linewidth=1.5,label='CF-ULF')
	plt.plot(x,cf2,linewidth=1.5,label='PureTrust')
	plt.plot(x,cf3,linewidth=1.5,label='Trust-CF-ULF')
	plt.plot(x,cf4,linewidth=1.5,label='INCF-P')
	plt.plot(x,cf5,linewidth=1.5,label='INCF-S')
	plt.plot(x,cf6,linewidth=1.5,label='INCF-PS')
    
	plt.xticks([10,20,30,40,50],('10','20','30','40','50'))
    
	legend = plt.legend(loc=0, shadow=True , fontsize ='xx-small')
	

	plt.xlabel('topN')
	plt.ylabel('coverage')
	# plt.title('flixster')
	plt.show()


	# plt.subplot(122)
	x = range(10,51,10)
	plt.plot(x,cb1,linewidth=1.5,label='CF-ULF')
	plt.plot(x,cb2,linewidth=1.5,label='PureTrust')
	plt.plot(x,cb3,linewidth=1.5,label='Trust-CF-ULF')
	plt.plot(x,cb4,linewidth=1.5,label='INCF-P')
	plt.plot(x,cb5,linewidth=1.5,label='INCF-S')
	plt.plot(x,cb6,linewidth=1.5,label='INCF-PS')
	plt.xticks([10,20,30,40,50],('10','20','30','40','50'))	
	legend = plt.legend(loc=3, shadow=True , fontsize ='xx-small' )
	

	plt.xlabel('topN')
	plt.ylabel('coverage')
	# plt.title('baidu')
    
    
    
	# fig.tight_layout()
	plt.show()
	
	
def loadData(fileName):
	codePath = sys.path[0]
	pathSet = codePath.split('\\')
	filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\baidu\\newfinalData\\'
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
	
def loadData_diversity_flixster(fileName):
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
	
def loadData_diversity_baidu(fileName):
	codePath = sys.path[0]
	pathSet = codePath.split('\\')
	filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\baidu\\newfinalData\\'
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

