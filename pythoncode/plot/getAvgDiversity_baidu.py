import sys




def main():
    codePath = sys.path[0]
    pathSet = codePath.split('\\')
    filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\baidu\\newfinalData\\'
    filePath = filePath + 'cmimTopNdiversity.txt'
    f = open(filePath,'w')
    
    
    basename = '\\result\\baidu\\som\\cmim\\'
    topNname = 'final_baidu_cmim_diversity_topK10.txt'
    filename = basename + topNname
    coverage,novelty = loaddata(filename)
    writeline = '%1.4f\t%1.4f\r\n' % (coverage,novelty)
    f.write(writeline)
    
    topNname = 'final_baidu_cmim_diversity_topK20.txt'
    filename = basename + topNname
    coverage,novelty = loaddata(filename)
    writeline = '%1.4f\t%1.4f\r\n' % (coverage,novelty)
    f.write(writeline)
 
    topNname = 'final_baidu_cmim_diversity_topK30.txt'
    filename = basename + topNname
    coverage,novelty = loaddata(filename)
    writeline = '%1.4f\t%1.4f\r\n' % (coverage,novelty)
    f.write(writeline) 
    
    
    topNname = 'final_baidu_cmim_diversity_topK40.txt'
    filename = basename + topNname
    coverage,novelty = loaddata(filename)
    writeline = '%1.4f\t%1.4f\r\n' % (coverage,novelty)
    f.write(writeline)
    
    topNname = 'final_baidu_cmim_diversity_topK50.txt'
    filename = basename + topNname
    coverage,novelty = loaddata(filename)
    writeline = '%1.4f\t%1.4f\r\n' % (coverage,novelty)
    f.write(writeline)

    f.close()
    
    print 'finished...'
    
def loaddata(filename):
    currentpath = sys.path[0]
    pathset = currentpath.split('\\')
    filepath = pathset[0]+'\\'+pathset[1]+'\\'+pathset[2]+filename
    f = open(filepath)
    dataset = f.readlines()
    f.close()
    
    result = []
    coverage,novelty = 0,0
    
    count = 0
    for line in dataset:
        c,n= map(float , line[:-1].split('\t'))
        coverage += c
        novelty += n

        count += 1
    coverage /= count
    novelty /= count

    
    
    return coverage,novelty
	
    
if __name__ == '__main__':
    main()