function interestCircleCell=SplitUserByInterestCircle2(weight,userRatingMatrix,itemClassIndex,ratingNumThreshold)
% ��ÿ���û��������ĳ��Ȥ��item��ֵĸ�������һ����ֵ�����仮�ֵ�����Ȥ��
% ����һ��Ԫ�飬ÿһ��cell��ʾ����������Ȥ�ڵ��û�ID��weight
% ����ÿ��cell����Ȩֵ�Ľ�������

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
%         interestCircle=-sortrows(-interestCircle,2); %��Ȩֵ��������
%         interestCircleCell{i}=interestCircle;
%     end
    



end