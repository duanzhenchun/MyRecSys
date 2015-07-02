clear;
tic

for version = 1:10
cfulfFile = sprintf('..\\..\\..\\result\\baidu\\cfulf\\allUserFinalRecList%d.mat',version);
puretrustFile = sprintf('..\\..\\..\\result\\baidu\\puretrust\\allUserFinalRecList%d.mat',version);
trustcfulfFile = sprintf('..\\..\\..\\result\\baidu\\trustcfulf\\allUserFinalRecList%d.mat',version);
pbmimFile =  sprintf('..\\..\\..\\result\\baidu\\som\\pbmim\\allUserFinalRecList%d.mat',version);
snmimFile =  sprintf('..\\..\\..\\result\\baidu\\som\\snmim\\allUserFinalRecList%d.mat',version);
cmimFile = sprintf('..\\..\\..\\result\\baidu\\som\\cmim\\allUserFinalRecList%d.mat',version);

load(cfulfFile,'allUserFinalRecList')
cfulfInfo = allUserFinalRecList;

load(puretrustFile,'allUserFinalRecList')
puretrustInfo = allUserFinalRecList;

load(trustcfulfFile,'allUserFinalRecList')
trustcfulfInfo = allUserFinalRecList;

load(pbmimFile,'allUserFinalRecList')
pbmimInfo = allUserFinalRecList;

load(snmimFile,'allUserFinalRecList')
snmimInfo = allUserFinalRecList;

load(cmimFile,'allUserFinalRecList')
cmimInfo = allUserFinalRecList;

testUserCount = length(cfulfInfo);
realUserCount = 0;
div1 = 0 ;div2 = 0;div3 = 0;div4 = 0;div5 = 0;div6 = 0;
M =6;
for i= 1:testUserCount

    m1Cell = cfulfInfo{i};
    m2Cell = puretrustInfo{i};
    m3Cell = trustcfulfInfo{i};
    m4Cell = pbmimInfo{i};
    m5Cell = snmimInfo{i};
    m6Cell = cmimInfo{i};
    totalHistList = [];
    if ~isempty(m1Cell)
        totalHistList = [totalHistList;m1Cell{3} ];
    end
    if ~isempty(m2Cell)
        totalHistList = [totalHistList;m2Cell{3} ];
    end
    if ~isempty(m3Cell)
        totalHistList = [totalHistList;m3Cell{3} ];
    end
    if ~isempty(m4Cell)
        totalHistList = [totalHistList;m4Cell{3} ];
    end
    if ~isempty(m5Cell)
        totalHistList = [totalHistList;m5Cell{3} ];
    end
    if ~isempty(m6Cell)
        totalHistList = [totalHistList;m6Cell{3} ];
    end

    if isempty(totalHistList)
        continue
    end
    realUserCount = realUserCount +1;
 	itemset = unique(totalHistList);
    itemnum = zeros(size(itemset));
    for k = 1:length(totalHistList)
        item = totalHistList(k);
        idx = find(itemset ==item );
        itemnum(idx) = itemnum(idx)+1 ;
    end
    item_prob = zeros(size(itemset));
    for k = 1:length(itemset)
        item_prob(k) = itemnum(k)/M;
    end
    
    div_u_1 = computeDiv(m1Cell,itemset,item_prob);
    div_u_2 = computeDiv(m2Cell,itemset,item_prob);
    div_u_3 = computeDiv(m3Cell,itemset,item_prob);
    div_u_4 = computeDiv(m4Cell,itemset,item_prob);
    div_u_5 = computeDiv(m5Cell,itemset,item_prob);
    div_u_6 = computeDiv(m6Cell,itemset,item_prob);
    
    div1 = div1 + div_u_1;
    div2 = div2 + div_u_2;
    div3 = div3 + div_u_3;
    div4 = div4 + div_u_4;
    div5 = div5 + div_u_5;
    div6 = div6 + div_u_6;
  
end
fprintf('finished....\n')
avgdiv1 = div1/realUserCount;
avgdiv2 = div2/realUserCount;
avgdiv3 = div3/realUserCount;
avgdiv4 = div4/realUserCount;
avgdiv5 = div5/realUserCount;
avgdiv6 = div6/realUserCount;

finalDiversityFileName = sprintf('..\\..\\..\\result\\baidu\\baidu_diversity.txt');
fid = fopen(finalDiversityFileName,'a');
fprintf(fid,'%f\t%f\t%f\t%f\t%f\t%f\r\n',avgdiv1,avgdiv2,avgdiv3,avgdiv4,avgdiv5,avgdiv6);
fclose(fid);

end







toc