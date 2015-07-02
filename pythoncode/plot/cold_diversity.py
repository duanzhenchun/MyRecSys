import sys
import matplotlib.pyplot as plt
import numpy as np

def main():

	cf = loadData_flixster()
	N = len(cf)
	idx = np.arange(N)
	width =0.5
	# fig = plt.figure(figsize=(7, 3), dpi=100,facecolor='w', edgecolor='k')
	# plt.subplot(1,2,1)
	plt.bar(idx, cf,  width, color=(0.8,0.0,0.0) )
	plt.xticks(idx+width/2.,('CF-ULF','PureTrust','Trust-CF-ULF','INCF-P','INCF-S','INCF-PS'),fontsize='small',rotation = '90')	
	plt.ylabel('coverage')
	plt.xlabel('algorithms')
	# plt.title('flixster')
	plt.tight_layout()    
	plt.show()    
    
	cb = loadData_baidu()
	N = len(cb)
	idx = np.arange(N)
	width =0.5

	# plt.subplot(1,2,2)
	plt.bar(idx, cb,  width, color=(0.0,0.5,0.0) )
	plt.xticks(idx+width/2.,('CF-ULF','PureTrust','Trust-CF-ULF','INCF-P','INCF-S','INCF-PS'),fontsize='small',rotation = '90')	
	plt.ylabel('coverage')
	plt.xlabel('algorithms')
	# plt.title('baidu')



	# fig.tight_layout()
	plt.tight_layout()    
	plt.show()
	
	

def loadData_baidu():
	codePath = sys.path[0]
	pathSet = codePath.split('\\')
	filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\baidu\\newfinalData\\'
	fileName = filePath + 'coldDiversity.txt'
	
	coverage = []

	f = open(fileName)
	dataSet = f.readlines()
	f.close()
    
	for line in dataSet:
		data = line[:-2]
		data= float(data)
		coverage.append(data)

	return coverage
	
def loadData_flixster():
	codePath = sys.path[0]
	pathSet = codePath.split('\\')
	filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\flixster\\newfinalData\\'
	fileName = filePath + 'coldDiversity.txt'
	
	coverage = []

	f = open(fileName)
	dataSet = f.readlines()
	f.close()
    
	for line in dataSet:
		data = line[:-2]
		data= float(data)
		coverage.append(data)

	return coverage
		
	
	
	
	
	
	
	
	
	
	
	
if __name__=='__main__':
	main()