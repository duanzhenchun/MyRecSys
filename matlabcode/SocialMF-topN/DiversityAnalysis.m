function [coverage,avgILS,avgPopularity]  = DiversityAnalysis(allUserFinalRecList, itemCount,itemSimiMatrix,itemPopularity)

allRecListSet=[];


totalILS=0;
realCount=0;  % 真正计算ILS的人数
testUserCount = length(allUserFinalRecList);
totalItrCover = 0;
totalPopularity=0;
for i=1:testUserCount
    recListCell=allUserFinalRecList{i};
    if isempty(recListCell)
        continue
    end
    recList=recListCell{2};
    allRecListSet=[allRecListSet recList'];   
    if length(recList)>1                   
        tempILS=GetIntraListSimi(recList,itemSimiMatrix);
        totalILS=totalILS+tempILS;   
        recPopularity = itemPopularity(recList,2);
        listPopularity = sum(recPopularity)/length(recList);
        totalPopularity = totalPopularity + listPopularity;
        realCount=realCount+1;       
    end  
end
avgILS=totalILS/realCount;    %  intra list similarity  
uniqueAllRecListSet=unique(allRecListSet);
coverage=length(uniqueAllRecListSet)/itemCount;    %推荐覆盖率
avgPopularity = totalPopularity/realCount;

end