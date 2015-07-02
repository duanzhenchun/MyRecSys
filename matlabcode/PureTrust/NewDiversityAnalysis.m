function [coverage,novelty]  = NewDiversityAnalysis(allUserFinalRecList,itemPopularity,itemCount,userCount)

allRecListSet=[];


realCount=0;  % ��������ILD������
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
        itemProbality = itemPopularity(recList,2)/userCount;
        listNovelty = - itemProbality .* log(itemProbality);
        sumlistNovelty= sum(listNovelty);
        totalNovelty = totalNovelty + sumlistNovelty;
        realCount=realCount+1;       
    end  
end

uniqueAllRecListSet=unique(allRecListSet);
coverage=length(uniqueAllRecListSet)/itemCount;    %�Ƽ�������
novelty = totalNovelty/realCount;

end