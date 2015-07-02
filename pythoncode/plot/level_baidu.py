import sys
import matplotlib.pyplot as plt
import numpy as np



def main():
    colorset = ['b','g','r','c','m','y']
   
    fig = plt.figure(figsize=(12, 5), dpi=100,facecolor='w', edgecolor='k')	
    level = 1    
    p,r,f = get_data(level)  
    N = len(p)
    idx = np.arange(N)    
    width =0.5   
    plt.subplot(2,3,1)   
    plt.bar(idx, p,  width, color= colorset[level-1])
    plt.xticks(idx+width/2.,('1','2','3','4','5','6'),fontsize='small')	
    plt.ylabel('precision')
    plt.xlabel('algorithms')
    plt.title('level %d' % level)
    
    
    level = 2    
    p,r,f = get_data(level)  
    plt.subplot(2,3,2)   
    plt.bar(idx, p,  width, color= colorset[level-1])
    plt.xticks(idx+width/2.,('1','2','3','4','5','6'),fontsize='small')	
    plt.ylabel('precision')
    plt.xlabel('algorithms')
    plt.title('level %d' % level)
    
    level = 3    
    p,r,f = get_data(level)  
    plt.subplot(2,3,3)   
    plt.bar(idx, p,  width, color= colorset[level-1])
    plt.xticks(idx+width/2.,('1','2','3','4','5','6'),fontsize='small')	
    plt.ylabel('precision')
    plt.xlabel('algorithms')
    plt.title('level %d' % level)
    
    level = 4    
    p,r,f = get_data(level)  
    plt.subplot(2,3,4)   
    plt.bar(idx, p,  width, color= colorset[level-1])
    plt.xticks(idx+width/2.,('1','2','3','4','5','6'),fontsize='small')	
    plt.ylabel('precision')
    plt.xlabel('algorithms')
    plt.title('level %d' % level)   
    
    level = 5    
    p,r,f = get_data(level)  
    plt.subplot(2,3,5)   
    plt.bar(idx, p,  width, color= colorset[level-1])
    plt.xticks(idx+width/2.,('1','2','3','4','5','6'),fontsize='small')	
    plt.ylabel('precision')
    plt.xlabel('algorithms')
    plt.title('level %d' % level)
    
    level = 6    
    p,r,f = get_data(level)  
    plt.subplot(2,3,6)   
    plt.bar(idx, p,  width, color= colorset[level-1])
    plt.xticks(idx+width/2.,('1','2','3','4','5','6'),fontsize='small')	
    plt.ylabel('precision')
    plt.xlabel('algorithms')
    plt.title('level %d' % level)
    
    fig.tight_layout()
    plt.figtext(0.50, 0.02,  '1:CF-ULF 2:PureTrust 3:Trust-CF-ULF 4:PMIM 5:SMIM 6:CMIM',fontsize='x-small', horizontalalignment='center')

    plt.show()
    
    
def get_data(level):
    cfulffn = 'cfulf\\final_baidu_cfulf_level_%d.txt' % level
    puretrustfn = 'puretrust\\final_baidu_puretrust_level_%d.txt' % level
    trustcfulffn = 'trustcfulf\\final_baidu_trustcfulf_level_%d.txt' % level
    pbmimfn = 'som\\pbmim\\final_baidu_pbmim_level_%d.txt' % level
    snmimfn = 'som\\snmim\\final_baidu_snmim_level_%d.txt' % level
    cmimfn = 'som\\cmim\\final_baidu_cmim_level_%d.txt' % level
    
    cfulf_p,cfulf_r,cfulf_f = load_data(cfulffn)
    puretrust_p,puretrust_r,puretrust_f = load_data(puretrustfn)
    trustcfulf_p,trustcfulf_r,trustcfulf_f = load_data(trustcfulffn)
    pbmim_p,pbmim_r,pbmim_f = load_data(pbmimfn)
    snmim_p,snmim_r,snmim_f = load_data(snmimfn)
    cmim_p,cmim_r,cmim_f = load_data(cmimfn)
    
    p = [cfulf_p,puretrust_p,trustcfulf_p,pbmim_p,snmim_p,cmim_p]
    r = [cfulf_r,puretrust_r,trustcfulf_r,pbmim_r,snmim_r,cmim_r]
    f = [cfulf_f,puretrust_f,trustcfulf_f,pbmim_f,snmim_f,cmim_f]
    
    return p,r,f
    
def load_data(filename):
    currentpath = sys.path[0]
    pathset = currentpath.split('\\')
    filepath = pathset[0]+'\\'+pathset[1]+'\\'+pathset[2]+'\\result\\baidu\\'+filename
    
    f = open(filepath)
    dataset = f.readlines()
    f.close()
    
    precision = 0
    recall = 0
    f1 = 0
    for line in dataset:
        p,r,f = map(float, line[:-1].split('\t'))
        precision += p
        recall += r
        f1 += f
        
    precision /= 10
    recall /= 10
    f1 /= 10
    
    return precision,recall, f1
    
    
    
    
if __name__=='__main__':
    main()