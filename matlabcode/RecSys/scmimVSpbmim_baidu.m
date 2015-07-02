

version = 4;
hitListFileName1 = sprintf('..\\..\\..\\data\\baidu\\somdata\\allUserHitList%d.mat',version);
hitListFileName2 = sprintf('..\\..\\..\\data\\baidu\\somdata\\2allUserHitList%d.mat',version);

hitStruct1 = load(hitListFileName1,'allUserHitList');
hitStruct2 = load(hitListFileName2,'allUserHitList');
pbHitListCell = hitStruct1.allUserHitList;
scHitListCell = hitStruct2.allUserHitList;

userCount = length(pbHitListCell);

totalDiffRate = 0;
count = 0;
for i = 1:userCount
   pbHitList = pbHitListCell{i};
   scHitList = scHitListCell{i};
   pbLen = length(pbHitList);
   scLen = length(scHitList);
   if scLen ==0
       continue
   end
%    intersecttList = intersect(pbHitList, scHitList);
%    sameLen = length(intersecttList);
   diffList = setdiff(scHitList,pbHitList);
   diffLen = length(diffList);
   diffRate = diffLen/scLen;
   totalDiffRate = totalDiffRate + diffRate;
   count = count + 1;
end

avgDiffRate = totalDiffRate/count;
fprintf('the avg diff rate is %f \n',avgDiffRate);
