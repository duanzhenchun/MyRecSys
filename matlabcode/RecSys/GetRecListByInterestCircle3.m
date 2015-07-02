function interestRecList=GetRecListByInterestCircle2(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,recThreshold,userAvgRating)
% �����û��ĵ�����ȤȦ�������Ƽ�
% ����һ���������е��Ƽ��б�����item����ź���ƽ�����

% recThreshold   ����������Ȥ�����Ƽ�ʱ����ÿ����ȤȦ�Ԥ������Ҫ���������ֵ�Żᱻ�Ƽ�


% *******************************ȡ��ÿ����Ȥ�û������ƶ�*****************************

% ����targetUser ����ȤС��ÿ���˵� ��Ȥ���ܶ�
itrUserCount=length(userInterestCircle);
interestAccep=zeros(itrUserCount,2);
interestAccep(:,1)=userInterestCircle(:,1);

% 
% for i=1:size(interestAccep,1)
%     interestUser=interestAccep(i,1);
%     % ���ù�ͬ����ȤȦ�ڴ����item������������
%     tx1=find(userRatingMatrix(interestUser,:)>0);
%     interestUserItem=intersect(tx1,itemInterestCircle);
%     tx2=find(userRatingMatrix(testUserID,:)>0);
%     testUserItem=intersect(tx2,itemInterestCircle);
%     commonItemNum=length(intersect(interestUserItem,testUserItem));
%     interestAccep(i,2)=commonItemNum;
% end

tempThreshold=0;

% ��ȡ����interset�û������Ϣ
urMatrix=userRatingMatrix(interestAccep(:,1),itemInterestCircle);
% �д�ֵ�ȫ������Ϊ1
urMatrix(urMatrix>tempThreshold)=1;
% ��ȡtestuser��Ϣ
testUserRating=userRatingMatrix(testUserID,itemInterestCircle);
% repmat
testUserRatingMatrix=repmat(testUserRating,itrUserCount,1);
testUserRatingMatrix(testUserRatingMatrix>tempThreshold)=1;
% ��ӣ��д�ֵĶ�Ϊ1�����Թ�ͬ����ֵ����Ϊ2
commonMatrix= urMatrix + testUserRatingMatrix;
unionMatrix= urMatrix + testUserRatingMatrix;
% ������2������Ϊ0
commonMatrix(commonMatrix~=2)=0;
% union �е�����Ϊ1
unionMatrix(unionMatrix>0)=1;
% ��Ϊ��2������2�飬����Ҫ����2
commonMatrix=commonMatrix/2;
interestAccep(:,2)=sum(commonMatrix,2);
unionBase=sum(unionMatrix,2);
% ��ֹ����0��ȫ������1
interestAccep(:,2)=interestAccep(:,2)+1;


% ########## ע�� �����Ұѷ�ĸ�ĳ���ȤȦ item �ܸ���+1�� ###########################
% interestAccep(:,2)=interestAccep(:,2)/(length(itemInterestCircle)+1);

% jaccard ���ƶ�
interestAccep(:,2)=interestAccep(:,2)./(unionBase+1);


% neighbor��Ȩ�� = ��Ȥ���ƶ�*����ȤȦ�ӵĹ�����
simiWeight=zeros(itrUserCount,2);
simiWeight(:,1)=userInterestCircle(:,1);
% simiWeight(:,2)=userInterestCircle(:,2);
simiWeight(:,2)=interestAccep(:,2);
% simiWeight(:,2)=userInterestCircle(:,2).*interestAccep(:,2);

% ȥ�� ���ƶ�Ϊ 0�� 
idx = find(simiWeight(:,2) >0);
simiWeight = simiWeight(idx,:);

% ����
simiWeight=-sortrows(-simiWeight,2);

% ����simiWeight ȡǰ�ٷ�֮ circlePeopleCutRate ��neighbor��������

% circlePeopleCutRate = 0.3;
% neighbourNum=ceil(size(simiWeight,1)*circlePeopleCutRate);
% neighbourNum=min(ceil(size(simiWeight,1)*circlePeopleCutRate),500);

% neighbourNum = size(simiWeight,1);
neighbourNum = min(size(simiWeight,1),200);

simiWeight=simiWeight(1:neighbourNum,:);


%********************************������Ȥ�û�����Эͬ����********************************

% % 
% % ��һ�д�itemID���ڶ��д���ƽ�����
% itemAvgWeightRating=zeros(length(itemInterestCircle),2);
% count=0;
% for i=1:length(itemInterestCircle)
%     
%     itemID=itemInterestCircle(i);
%     totalWeightRating=0;
%     totalWeight=0;
%     for j=1:size(simiWeight,1)
%         simiUserID=simiWeight(j,1);
%         weight=simiWeight(j,2);
%         rt=userRatingMatrix(simiUserID,itemID);
%         if rt==0
%             continue;
%         else
%             totalWeightRating=totalWeightRating+rt*weight;
%             totalWeight=totalWeight+weight;
%         end
%     end
%     
%     % ���û��Ȧ����û���û������item���
%     if totalWeightRating==0
%        % ��ΪtotalWeightҲ��0������ֱ�Ӹ�0
%        avgrt=0;    
%        count=count+1;
%     else
%         % ���Ȩƽ��ֵ
%         avgrt=totalWeightRating/totalWeight;
%     end
%     itemAvgWeightRating(i,1)=itemID;
%     itemAvgWeightRating(i,2)=avgrt; 
% 
% end



% ��һ�д�itemID���ڶ��д����Ȩƽ�����
itemAvgWeightRating=zeros(length(itemInterestCircle),3);
itemAvgWeightRating(:,1)=itemInterestCircle;
% ������Ȥ�û�������item�Ĵ��
irMatrix=userRatingMatrix(simiWeight(:,1),itemInterestCircle);
% 0 index
% irMatrix(irMatrix>0) = 1;
zeroIndex = irMatrix==0;

simiMatrix=repmat(simiWeight(:,2),1,length(itemInterestCircle));
simiMatrix(zeroIndex)=0;
% ���
weightedRatingMatrix=irMatrix.*simiMatrix;
sumWeightedRating=sum(weightedRatingMatrix,1);
itemAvgWeightRating(:,2)=sumWeightedRating;
% sumWeight=sum(simiMatrix,1);
% itemAvgWeightRating(:,2)=sumWeightedRating./sumWeight;

% commonMatrix = irMatrix>0;
% commonMatrix(zeroIndex) = 0;
% commonVec = sum(commonMatrix,1);

% itemAvgWeightRating(:,2) = itemAvgWeightRating(:,2) / ( sum(simiWeight(:,2)) );
itemAvgWeightRating(:,2) = itemAvgWeightRating(:,2) / ( 5 * sum(simiWeight(:,2)));

% itemAvgWeightRating(:,3)  = commonVec';

% ȥ��nan
idx=isnan(itemAvgWeightRating(:,2));
itemAvgWeightRating(idx,2)=0;


% ����
itemAvgWeightRating=-sortrows(-itemAvgWeightRating,2);
% ����recThreshold ����һЩ���ֲ�̫�ߵ�item, *** ���Գ��Լ��� = �� ***


% kx2=find(itemAvgWeightRating(:,2)>=recThreshold);
% itemAvgWeightRating=itemAvgWeightRating(kx2,:);


interestRecList=itemAvgWeightRating;

end