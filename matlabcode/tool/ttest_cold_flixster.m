 clear;
 clc;
 
topK = 50;

cfulfName = sprintf('..\\..\\..\\result\\flixster\\cfulf\\final_flixster_cfulf_colduser_topK%d.txt',topK);
puretrustName = sprintf('..\\..\\..\\result\\flixster\\puretrust\\final_flixster_puretrust_colduser_topK%d.txt',topK);
trustcfulfName = sprintf('..\\..\\..\\result\\flixster\\trustcfulf\\final_flixster_trustcfulf_colduser_topK%d.txt',topK);
pbmimName=sprintf('..\\..\\..\\result\\flixster\\som\\pbmim\\final_flixster_pbmim_colduser_topK%d.txt',topK);
snmimName=sprintf('..\\..\\..\\result\\flixster\\som\\snmim\\final_flixster_snmim_colduser_topK%d.txt',topK);
cmimName=sprintf('..\\..\\..\\result\\flixster\\som\\cmim\\final_flixster_cmim_colduser_topK%d.txt',topK);

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

