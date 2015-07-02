import sys
import matplotlib.pyplot as plt


def main():

    x,yp,yr,yf  = getdata()
    
    fig = plt.figure(figsize=(8, 6), dpi=100,facecolor='w', edgecolor='k')
    
    plt.subplot(311)
    plt.xlim(0.05,0.3)
    plt.plot(x,yp,linewidth=1.5,color=(0.8,0.0,0.0))
    # plt.xlabel('alpha')
    plt.ylabel('precision')
    
    plt.subplot(312)
    plt.xlim(0.05,0.3)
    plt.plot(x,yr,linewidth=1.5,color=(0.0,0.5,0.0))
    # plt.xlabel('alpha')
    plt.ylabel('recall')

     
    plt.subplot(313)
    plt.xlim(0.05,0.3)
    plt.plot(x,yf,linewidth=1.5,color='#3399CC')
    plt.xlabel('beta')
    plt.ylabel('f1')
    
    
    fig.tight_layout()
    plt.show()

def getdata():

    x =[x/100.0 for x in range(5,35,5)]

    yp = []
    yr = []
    yf = []

    filenamestart = 'final_movielens_pbmim_prf_top20_beta' 
    filenameend = '_neighbor20.txt'
    alphaset = ['0.05','0.10','0.15','0.20','0.25','0.30']
    for alpha in alphaset:
        filename = filenamestart + alpha + filenameend
        p,r,f = loaddata(filename)
        yp.append(p)
        yr.append(r)
        yf.append(f)
        
    return x,yp,yr,yf
    
    
def loaddata(filename):
    currentpath = sys.path[0]
    pathset = currentpath.split('\\')
    filepath = pathset[0]+'\\'+pathset[1]+'\\'+pathset[2]+'\\result\\movielens\\som\\pbmim\\'+filename
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