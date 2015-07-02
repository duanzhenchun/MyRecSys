import sys
import matplotlib.pyplot as plt


def main():

	p1,r1,f1 = getdata('som\\pbmim\\final_movielens_pbmim_prf_top20_beta0.10_neighbor')
	p2,r2,f2 = getdata('userCF\\final_movielens_userCF_prf_top20_neighbor')
	p3,r3,f3 = getdata('itemCF\\final_movielens_itemCF_prf_top20_neighbor')
    

    
	fig = plt.figure(figsize=(11, 3), dpi=100,facecolor='w', edgecolor='k')
	plt.rc('axes', color_cycle=[(0.8,0.0,0.0),(0.0,0.5,0.0),'#3399CC'])
	plt.subplot(131)

	# ********************* plot precision **********************************
	x = range(10,51,10)
	plt.plot(x,p1,linewidth=1.5,label='MCF',linestyle = '-')
	plt.plot(x,p2,linewidth=1.5,label='UserCF',linestyle= '--')
	plt.plot(x,p3,linewidth=1.5,label='ItemCF',linestyle= '-.')

    
	plt.xticks([10,20,30,40,50],('10','20','30','40','50'))
    
	legend = plt.legend(loc=0, shadow = True , fontsize ='xx-small')
	

	plt.xlabel('neighbor')
	plt.ylabel('precision')


	#********************* plot recall **********************************
	plt.subplot(132)
	x = range(10,51,10)
	plt.plot(x,r1,linewidth=1.5,label='MCF',linestyle = '-')
	plt.plot(x,r2,linewidth=1.5,label='UserCF',linestyle= '--')
	plt.plot(x,r3,linewidth=1.5,label='ItemCF',linestyle= '-.')

	plt.xticks([10,20,30,40,50],('10','20','30','40','50'))	
	legend = plt.legend(loc=0, shadow=True, fontsize ='xx-small' )
	

	plt.xlabel('neighbor')
	plt.ylabel('recall')

	
	#********************* plot f1 **********************************
	plt.subplot(133)
	x = range(10,51,10)
	plt.plot(x,f1,linewidth=1.5,label='MCF',linestyle = '-')
	plt.plot(x,f2,linewidth=1.5,label='UserCF',linestyle= '--')
	plt.plot(x,f3,linewidth=1.5,label='ItemCF',linestyle= '-.')

	plt.xticks([10,20,30,40,50],('10','20','30','40','50'))	
	legend = plt.legend(loc=0, shadow=True , fontsize ='xx-small' )
	
	plt.xlabel('neighbor')
	plt.ylabel('f1')
	
	
	fig.tight_layout()
	plt.show()
	

def getdata(basename):

    yp = []
    yr = []
    yf = []

    neighbors = ['10','20','30','40','50']
    for n in neighbors:
        filename = basename + n + '.txt'
        p,r,f = loaddata(filename)
        yp.append(p)
        yr.append(r)
        yf.append(f)
        
    return yp,yr,yf
    
    
def loaddata(filename):
    currentpath = sys.path[0]
    pathset = currentpath.split('\\')
    filepath = pathset[0]+'\\'+pathset[1]+'\\'+pathset[2]+'\\result\\movielens\\'+filename
    f = open(filepath)
    dataset = f.readlines()
    f.close()
    
    result = []
    precision,recall,f1 = 0,0,0
    
    count = 0
    for line in dataset:
        p,r,f = map(float , line[:-1].split('\t'))
        precision += p
        recall += r
        f1 += f
        count += 1
    precision /= count
    recall /= count
    f1 /=count
    
    return precision,recall,f1
	
    
if __name__ == '__main__':
    main()