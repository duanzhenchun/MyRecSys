function [coverage,avgILD,novelty]  = DiversityAnalysis(allUserFinalRecList,itemDistMatrix,itemPopularity,itemCount,userCount)

allRecListSet=[];


totalILD=0;
realCount=0;  % 真正计算ILD的人数
testUserCount = length(allUserFinalRecList);
totalNovelty=0;
for i=1:testUserCount
    recListCell=allUserFinalRecList{i};
    if isempty(recListCell)
        continue
    end
    recList=recListCell{2};
    allRecListSet=[allRecListSet recList'];   
    if length(recList)>1                   
        tempILD=GetIntraListSimi(recList,itemDistMatrix);
        totalILD=totalILD+tempILD;   
        itemProbality = itemPopularity(recList,2)/userCount;
        listNovelty = - itemProbality .* log(itemProbality);
        sumlistNovelty= sum(listNovelty);
        totalNovelty = totalNovelty + sumlistNovelty;
        realCount=realCount+1;       
    end  
end
avgILD=totalILD/realCount;    %  intra list similarity  
uniqueAllRecListSet=unique(allRecListSet);
coverage=length(uniqueAllRecListSet)/itemCount;    %推荐覆盖率
novelty = totalNovelty/realCount;

end