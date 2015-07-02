function interestCircleCell=SplitUserByInterestCircle2(weight,userRatingMatrix,itemClassIndex,ratingNumThreshold)
% 对每个用户，若其对某兴趣中item打分的个数超过一定阈值，则将其划分到该兴趣中
% 返回一个元组，每一个cell表示归属到该兴趣内的用户ID和weight
% 并且每个cell都按权值的降序排列

interestCircleNum=size(weight,1);
interestCircleCell=cell(interestCircleNum,1);
userCount=size(userRatingMatrix,1);
for i=1:interestCircleNum
    irtItemSet=itemClassIndex==i;
    irtItemMatrix=repmat(irtItemSet,userCount,1);
    userItemMatrix=userRatingMatrix>0;
    commonMatrix=userItemMatrix+irtItemMatrix;
    commonMatrix(commonMatrix~=2)=0;
    commonMatrix=commonMatrix/2;
    commonItemNum=sum(commonMatrix,2);
    userIDSet=find(commonItemNum>=ratingNumThreshold);
    interestCircle=zeros(length(userIDSet),2);
    interestCircle(:,1)=userIDSet;
    interestCircle(:,2)=1;
    interestCircleCell{i}=interestCircle;
    
    
    
%     for j=1:userCount
%         userRating=userRatingMatrix(j,:);
%         userItemSet=find(userRating>0);
%         crossItemSet=intersect(irtItemSet,userItemSet);
%         if length(crossItemSet)>=ratingNumThreshold
%             userIDSet(j)=j;
%         end          
%     end
%     idx=find(userIDSet==0);
%     userIDSet(idx)=[];
%     interestCircle=zeros(length(userIDSet),2);
%     interestCircle(:,1)=userIDSet;
%     interestCircle(:,2)=1;
%     interestCircleCell{i}=interestCircle;

end  


%     tempWeight=weight(i,:);
%     idx=find(tempWeight>=ratingNumThreshold);
%     if ~isempty(idx)
%         interestCircle=zeros(length(idx),2);
%         interestCircle(:,1)=idx;  %user id
%         interestCircle(:,2)=tempWeight(idx);
%         interestCircle=-sortrows(-interestCircle,2); %按权值降序排列
%         interestCircleCell{i}=interestCircle;
%     end
    



end