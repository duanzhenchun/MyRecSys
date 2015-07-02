import sys
import matplotlib.pyplot as plt
import numpy as np

def main():
	p,r,f = loadData()
	
	
	N = len(p)
	idx = np.arange(N)
	width =0.5
	# fig = plt.figure(figsize=(9, 3), dpi=100,facecolor='w', edgecolor='k')
	# plt.subplot(1,3,1)
	plt.bar(idx, p,  width, color=(0.8,0.0,0.0) )
	plt.xticks(idx+width/2.,('CF-ULF','PureTrust','Trust-CF-ULF','INCF-P','INCF-S','INCF-PS'),fontsize='small',rotation = '90')	
	plt.ylabel('precision')
	plt.xlabel('algorithms')
	plt.tight_layout()
	plt.show()
	
	# plt.subplot(1,3,2)
	plt.bar(idx, r,width, color=(0.0,0.5,0.0))
	plt.xticks(idx+width/2.,('CF-ULF','PureTrust','Trust-CF-ULF','INCF-P','INCF-S','INCF-PS'),fontsize='small',rotation = '90')
	plt.ylabel('recall')
	plt.xlabel('algorithms')
	plt.tight_layout()
	plt.show()
	
	
	# plt.subplot(1,3,3)
	plt.bar(idx, f, width, color='#3399CC')
	plt.xticks(idx+width/2.,('CF-ULF','PureTrust','Trust-CF-ULF','INCF-P','INCF-S','INCF-PS'),fontsize='small',rotation = '90')
	plt.ylabel('f1')
	plt.xlabel('algorithms')

	# fig.tight_layout()
	plt.tight_layout()    
	plt.show()
	
	

def loadData():
	codePath = sys.path[0]
	pathSet = codePath.split('\\')
	filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\baidu\\newfinalData\\'
	fileName = filePath + 'coldstart.txt'
	
	precision = []
	recall = []
	f1 = []
	
	f = open(fileName)
	dataSet = f.readlines()
	f.close()
	for line in dataSet:
		data = line[:-2].split('\t')
		data= map(float,data)
		precision.append(data[0])
		recall.append(data[1])
		f1.append(data[2])
	
	
	# fileName2 = filePath + 'coldstartStd.txt'
	# precisionStd = []
	# recallStd = []
	# f1Std = []
	
	# f2 = open(fileName2)
	# dataSet2 = f2.readlines()
	# f2.close()
	# for line in dataSet2:
		# data = line[:-2].split('\t')
		# data= map(float,data)
		# precisionStd.append(data[0])
		# recallStd.append(data[1])
		# f1Std.append(data[2])
	
	
	
	return precision,recall,f1
	
	
	
	
	
	
	
	
	
	
	
	
	
if __name__=='__main__':
	main()