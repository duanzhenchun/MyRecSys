function [coverage,avgILD,novelty]  = DiversityAnalysis(allUserFinalRecList,itemDistMatrix,itemPopularity,itemCount,userCount)

allRecListSet=[];


totalILD=0;
realCount=0;  % 真正计算ILD的人数
testUserCount = length(allUserFinalRecList);
totalNovelty=0;
specialCount = 0;
for i=1:testUserCount
    recListCell=allUserFinalRecList{i};
    if isempty(recListCell)
        continue
    end
    recList=recListCell{2};
    allRecListSet=[allRecListSet recList'];   
    if length(recList)>=1
        if length(recList) == 1
            tempILD = 0;
            specialCount = specialCount+1;
        else
            tempILD=GetIntraListSimi(recList,itemDistMatrix)/2;
        end
        totalILD=totalILD+tempILD;   
        
        itemProbality = itemPopularity(recList,2)/userCount;
        listNovelty = -log(itemProbality);
        sumlistNovelty= sum(listNovelty);
        avgNovelty = sumlistNovelty/100;
        totalNovelty = totalNovelty + avgNovelty;
        realCount=realCount+1;       
    end  
end
avgILD=totalILD/realCount;    %  intra list similarity  
uniqueAllRecListSet=unique(allRecListSet);
coverage=length(uniqueAllRecListSet)/itemCount;    %推荐覆盖率
novelty = totalNovelty/realCount;
fprintf('special count is %d',specialCount);
end