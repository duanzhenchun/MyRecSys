

% hitListFileName1 = sprintf('..\\..\\..\\data\\flixster\\somdata\\allUserHitList%d.mat',version);
% hitListFileName2 = sprintf('..\\..\\..\\data\\flixster\\cfulfdata\\allUserHitList%d.mat',version);

% hitListFileName1 = sprintf('..\\..\\..\\data\\flixster\\somdata\\2allUserHitList%d_50.mat',version);
% hitListFileName2 = sprintf('..\\..\\..\\data\\flixster\\puretrustdata\\2allUserHitList%d_50.mat',version);

hitListFileName1 =  sprintf('..\\..\\..\\data\\flixster\\somdata\\3allUserHitList%d_50.mat',version);
hitListFileName2 = sprintf('..\\..\\..\\data\\flixster\\trustcfulfdata\\3allUserHitList%d_50.mat',version);

version = 2;

hitStruct1 = load(hitListFileName1,'allUserHitList');
hitStruct2 = load(hitListFileName2,'allUserHitList');
newHitListCell = hitStruct1.allUserHitList;
oldHitListCell = hitStruct2.allUserHitList;

userCount = length(newHitListCell);
posCount1 = 0;
negCount1 = 0;
eqCount = 0;

posCount2 = 0;
negCount2 =0;

for i = 1:userCount
   newHitList = newHitListCell{i};
   oldHitList = oldHitListCell{i};
   newLen = length(newHitList);
   oldLen = length(oldHitList);
   intersecttList = intersect(newHitList, oldHitList);
   intLen = length(intersecttList);
   if newLen>oldLen
       posCount1 = posCount1 + 1;
       if intLen == oldLen
           posCount2 = posCount2+1;
       end
   elseif newLen<oldLen
       negCount1 = negCount1 + 1;
       if intLen == newLen
           negCount2 = negCount2 + 1;
       end
   elseif newLen == oldLen
       eqCount = eqCount + 1;
   end
   
 
   
      
end

fprintf('posCount1 is %d, negCount1 is %d, eqCount is %d \n',posCount1,negCount1,eqCount);
fprintf('posCount2 is %d, negCount2 is %d \n',posCount2,negCount2);
