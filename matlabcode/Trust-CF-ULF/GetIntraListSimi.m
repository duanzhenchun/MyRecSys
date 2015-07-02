function ILS=GetIntraListSimi(recList,itemSimiMatrix)
% calculate the intra list similarity  
% prepare for the calculation of diversity

listCount=length(recList);
sumILS=sum(sum(itemSimiMatrix(recList,recList)));
ILS=sumILS/(listCount*(listCount-1));
    
end