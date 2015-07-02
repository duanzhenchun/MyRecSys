 clear;
 clc;
 
topK = 50;

cfulfName = sprintf('..\\..\\..\\result\\baidu\\cfulf\\final_baidu_cfulf_colduser_topK%d.txt',topK);
puretrustName = sprintf('..\\..\\..\\result\\baidu\\puretrust\\final_baidu_puretrust_colduser_topK%d.txt',topK);
trustcfulfName = sprintf('..\\..\\..\\result\\baidu\\trustcfulf\\final_baidu_trustcfulf_colduser_topK%d.txt',topK);
pbmimName=sprintf('..\\..\\..\\result\\baidu\\som\\pbmim\\final_baidu_pbmim_colduser_topK%d.txt',topK);
snmimName=sprintf('..\\..\\..\\result\\baidu\\som\\snmim\\final_baidu_snmim_colduser_topK%d.txt',topK);
cmimName=sprintf('..\\..\\..\\result\\baidu\\som\\cmim\\final_baidu_cmim_colduser_topK%d.txt',topK);

cfulf = load(cfulfName);
puretrust = load(puretrustName);
trustcfulf = load(trustcfulfName);
pbmim = load(pbmimName);
snmim = load(snmimName);
cmim = load(cmimName);


col = 3;
cfulf_current = cfulf(:,col);
puretrust_current = puretrust(:,col);
trustcfulf_current = trustcfulf(:,col);
pbmim_current = pbmim(:,col);
snmim_current = snmim(:,col);
cmim_current = cmim(:,col);

mat = [cmim_current cfulf_current  puretrust_current trustcfulf_current pbmim_current snmim_current];

meanmat = mean(mat)
stdmat = std(mat)


[h1,p1] = ttest(cmim_current,cfulf_current,0.05,'right');
[h2,p2] = ttest(cmim_current,puretrust_current,0.05,'right');
[h3,p3] = ttest(cmim_current,trustcfulf_current,0.05,'right');
[h4,p4] = ttest(cmim_current,pbmim_current,0.05,'right');
[h5,p5] = ttest(cmim_current,snmim_current,0.05,'right');

hmat = [h1;h2;h3;h4;h5]
pmat = [p1;p2;p3;p4;p5]'

