import sys




def main():
    codePath = sys.path[0]
    pathSet = codePath.split('\\')
    filePath = pathSet[0]+'\\'+pathSet[1]+'\\'+pathSet[2]+'\\data\\baidu\\newfinalData\\'
    filePath = filePath + 'coldstart.txt'
    f = open(filePath,'w')
    
    
    basename = '\\result\\baidu\\cfulf\\'
    topNname = 'final_baidu_cfulf_colduser_topK50.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
    f.write(writeline)
        
    basename = '\\result\\baidu\\puretrust\\'
    topNname = 'final_baidu_puretrust_colduser_topK50.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
    f.write(writeline)
 
    basename = '\\result\\baidu\\trustcfulf\\'
    topNname = 'final_baidu_trustcfulf_colduser_topK50.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
    f.write(writeline) 
    
    
    basename = '\\result\\baidu\\som\\pbmim\\'
    topNname = 'final_baidu_pbmim_colduser_topK50.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
    f.write(writeline)
    
    basename = '\\result\\baidu\\som\\snmim\\'
    topNname = 'final_baidu_snmim_colduser_topK50.txt'
    filename = basename + topNname
    precision,recall,f1 = loaddata(filename)
    writeline = '%1.4f\t%1.4f\t%1.4f\r\n' % (precision,recall,f1)
    f.write(writeline)

    basename = '\\result\\baidu\\som\\cmim\\'
    topNname = 'final_baidu_cmim_colduser_topK50.txt'
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