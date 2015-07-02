import sys




def main():
    codePath = sys.path[0]
    pathSet = codePath.split('\\')
    filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\baidu\\newfinalData\\'
    filePath = filePath + 'trustcfulfTopN.txt'
    f = open(filePath,'w')
    
    
    basename = '\\result\\baidu\\trustcfulf\\'
    topNname = 'final_baidu_trustcfulf_prf_top10.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
    f.write(writeline)
    
    topNname = 'final_baidu_trustcfulf_prf_top20.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
    f.write(writeline)
 
    topNname = 'final_baidu_trustcfulf_prf_top30.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
    f.write(writeline) 
    
    
    topNname = 'final_baidu_trustcfulf_prf_top40.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
    f.write(writeline)
    
    topNname = 'final_baidu_trustcfulf_prf_top50.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
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