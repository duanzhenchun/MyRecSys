% function SocialEffectAnalysis(oldRecInfo,newRecInfo,itemClassIndex,levelNum)
clear;
versionSum=10;

for version=1:versionSum
% version = 1;
fprintf('---------------the current version is %d ----------------- \n',version);
width = 10;
height = 8;
ratingSomFileName=sprintf('..\\..\\..\\data\\flixster\\somdata\\flixster_%dx%d_som%d.mat',width,height,version); 
oldRecInfoFileName = sprintf('..\\..\\..\\data\\flixster\\somdata\\oldRecInfo%d.mat',version);
newRecInfoFileName = sprintf('..\\..\\..\\data\\flixster\\somdata\\newRecInfo%d.mat',version);
load(oldRecInfoFileName,'oldRecInfo');
load(newRecInfoFileName,'newRecInfo');
load(ratingSomFileName, 'itemClassIndex');

levelNum = 6;
userCount = length(oldRecInfo);
totalChangedPrecision = 0;
totalChangedRecall = 0;
realCount = 0 ;
effectType1 = 0;
effectType2 = 0;
effectType3 = 0;
effectType0 = 0;


e3precision=0;
e3recall =0 ;
e2precision=0;
e2recall =0 ;
e1precision=0;
e1recall=0;

negativeCount = 0;
allUserChangedEvaluation = ones(userCount,8)*(-100);

for i = 1: userCount
    
    oldRecInfoCell = oldRecInfo{i};
    if isempty(oldRecInfoCell)
        continue
    end
    
    newRecInfoCell = newRecInfo{i};
    testUser = oldRecInfoCell{1};
    oldHitList = oldRecInfoCell{2};
    newHitList = newRecInfoCell{2};
    testItemLen = oldRecInfoCell{3}; % 测试集里的打分个数
    oldInterestSet = oldRecInfoCell{4};
    newInterestSet = newRecInfoCell{4};
    level = oldRecInfoCell{5};    
    topK = oldRecInfoCell{6};       
    socialInrerestSet = setdiff(newInterestSet, oldInterestSet);   
    changedHitNum = length(newHitList) - length(oldHitList);
    
    changedPrecision = changedHitNum / topK;
    changedRecall = changedHitNum / testItemLen;
    totalChangedPrecision = totalChangedPrecision + changedPrecision;
    totalChangedRecall = totalChangedRecall + changedRecall;
    
    diffHitList = setdiff(newHitList, oldHitList);
    diffHitInterestSet = itemClassIndex(diffHitList);
    
    socialItrHit = intersect(diffHitInterestSet,socialInrerestSet );  % 看看与social时的兴趣重合的情况
    socialItrHitLen = length(socialItrHit);
   
   if isempty(diffHitList) && (length(newHitList) == length(oldHitList))
       effectType0 = effectType0 +1;
       realCount = realCount + 1;
       allUserChangedEvaluation(i, :) = [testUser,0,0,0,0,0,0,level];
       continue;
   end
    
   if socialItrHitLen == 0 && ~isempty(diffHitList)
       effectType = 2;
       effectType2 = effectType2 + 1;
       e2precision = e2precision + changedPrecision;
       e2recall = e2recall + changedRecall;
       allUserChangedEvaluation(i, :) = [testUser,0,0,changedPrecision,changedRecall,0,0,level];
   elseif socialItrHitLen >0 && socialItrHitLen == length(diffHitInterestSet);
       effectType = 1;
       effectType1 = effectType1 + 1;
       e1precision = e1precision + changedPrecision;
       e1recall = e1recall + changedRecall;
       allUserChangedEvaluation(i, :) = [testUser,changedPrecision,changedRecall,0,0,0,0,level];
%   elseif socialItrHitLen >0 && socialItrHitLen < length(diffHitInterestSet);
   elseif (socialItrHitLen >0 && socialItrHitLen < length(diffHitInterestSet)) || (socialItrHitLen == 0 && isempty(diffHitList))
       if socialItrHitLen == 0 && isempty(diffHitList)
           negativeCount = negativeCount+1;
       end
       effectType = 3;
       effectType3 = effectType3 + 1;
       allUserChangedEvaluation(i, :) = [testUser,0,0,0,0,changedPrecision,changedRecall,level];
   end
   
   
   realCount = realCount + 1;
end

a = realCount - effectType0-effectType1-effectType2-effectType3;
if a>0
    disp('aha~~~~~~~~~')
end

fprintf('negative count is %d,effect 3 is %d \r\n',negativeCount,effectType3);

avgChangedPrecision = totalChangedPrecision / realCount;
avgChangedRecall = totalChangedRecall / realCount;


avgUserChangedEvaluationByLevel=zeros(levelNum,7);
for i=1:levelNum
    level=i;
    idx=find(allUserChangedEvaluation(:,8)==level);

    avgPrecision1=sum(allUserChangedEvaluation(idx,2))/length(idx);
    avgRecall1=sum(allUserChangedEvaluation(idx,3))/length(idx);
    avgPrecision2=sum(allUserChangedEvaluation(idx,4))/length(idx);
    avgRecall2=sum(allUserChangedEvaluation(idx,5))/length(idx);
    avgPrecision3=sum(allUserChangedEvaluation(idx,6))/length(idx);
    avgRecall3=sum(allUserChangedEvaluation(idx,7))/length(idx);
    
    avgUserChangedEvaluationByLevel(i,1)=level;
    avgUserChangedEvaluationByLevel(i,2)=avgPrecision1;
    avgUserChangedEvaluationByLevel(i,3)=avgRecall1;
    avgUserChangedEvaluationByLevel(i,4)=avgPrecision2;
    avgUserChangedEvaluationByLevel(i,5)=avgRecall2;
    avgUserChangedEvaluationByLevel(i,6)=avgPrecision3;
    avgUserChangedEvaluationByLevel(i,7)=avgRecall3;
    

    
    SocialEffectFileName = sprintf('..\\..\\..\\result\\flixster\\som\\cmim\\flixster_SocialEffect_level%d.txt',i);
    fid = fopen(SocialEffectFileName,'a');
    fprintf(fid,'%f\t%f\t%f\t%f\t%f\t%f\r\n',avgUserChangedEvaluationByLevel(i,2),avgUserChangedEvaluationByLevel(i,3),avgUserChangedEvaluationByLevel(i,4),avgUserChangedEvaluationByLevel(i,5),avgUserChangedEvaluationByLevel(i,6),avgUserChangedEvaluationByLevel(i,7));
    fclose(fid); 

end




end