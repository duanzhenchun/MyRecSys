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
realCount = 0 ;

newAllUserEvaluation=zeros(userCount,4);
oldAllUserEvaluation=zeros(userCount,4);
totalPrecision = 0; totalRecall = 0;
for i = 1: userCount
    
    oldRecInfoCell = oldRecInfo{i};
    if isempty(oldRecInfoCell)
        continue
    end   
    newRecInfoCell = newRecInfo{i};
    if isempty(newRecInfoCell)
        continue
    end   
    
    testUser = oldRecInfoCell{1};
    oldHitList = oldRecInfoCell{2};
    newHitList = newRecInfoCell{2};
    testItemLen = oldRecInfoCell{3}; % 测试集里的打分个数
    oldInterestSet = oldRecInfoCell{4};
    newInterestSet = newRecInfoCell{4};
    level = oldRecInfoCell{5};    
    topK = oldRecInfoCell{6};  
    
    newPrecision = length(newHitList)/topK;
    newRecall = length(newHitList)/testItemLen;
    
    oldPrecision = length(oldHitList)/topK;
    oldRecall = length(oldHitList)/testItemLen;
    
    newAllUserEvaluation(i,:) = [testUser,newPrecision,newRecall,level];
    oldAllUserEvaluation(i,:) = [testUser,oldPrecision,oldRecall,level];

    totalPrecision = totalPrecision + newPrecision;
    totalRecall = totalRecall + newRecall;
    
  
    realCount = realCount + 1;
end

% avgPrecision = totalPrecision/realCount;
% avgRecall = totalRecall/realCount;

% fprintf('the precision is %f, the recall is %f  \r\n',avgPrecision,avgRecall);


newAvgUserEvaluationByLevel = EvaluationAnalysis(newAllUserEvaluation, levelNum);
for levelIdx = 1: 6
levelFileName = sprintf('..\\..\\..\\result\\flixster\\som\\cmim\\final_flixster_cmim_level%d.txt',levelIdx);

fid = fopen(levelFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',newAvgUserEvaluationByLevel(levelIdx,2),newAvgUserEvaluationByLevel(levelIdx,3),newAvgUserEvaluationByLevel(levelIdx,4));
fclose(fid);
end

oldAvgUserEvaluationByLevel = EvaluationAnalysis(oldAllUserEvaluation, levelNum);
for levelIdx = 1: 6
levelFileName = sprintf('..\\..\\..\\result\\flixster\\som\\pbmim\\final_flixster_pbmim_level%d.txt',levelIdx);

fid = fopen(levelFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',oldAvgUserEvaluationByLevel(levelIdx,2),oldAvgUserEvaluationByLevel(levelIdx,3),oldAvgUserEvaluationByLevel(levelIdx,4));
fclose(fid);
end


end