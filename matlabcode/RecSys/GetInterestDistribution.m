clear;
clc;
%% ����û�����Ȥ�ķֲ�������Դ�������ȡ�û�ǰ�ٷ�֮���ٵ���Ȥ
%% ��������
load ratingSomOutcome1.mat ...
    uniqUserData uniqItemData ...
    userRatingMatrix weight itemClassIndex
%% ��ʼ��
% �ٷֱ�����
percentList=(0.05:0.05:1);
percentWeightList=zeros(1,length(percentList));

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
% �������û���Ȩ�ذ���������
allSortedWeightCell=GetAllSortedWeight(weight);
% ������item���ֵ���ͬ����
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,size(weight,1));
%% ��ʼ����
for i=1:length(percentList)

    interestPercent=percentList(i);
    percentWeight=0;
    for j=1:userCount

        %ȡ��Ŀ���û���ȤȨֵ,�����û�������>0����Ȥ
        interestWeight=allSortedWeightCell{j};
        tx0=find(interestWeight(:,2)>0);
        interestWeight=interestWeight(tx0,:);
        
        % Ҫȡ��ǰ���ٸ���Ȥ,����ȥ��������������Ȥ����
        
        % ����Ȥ����
        totalInterestNum=size(interestWeight,1);             
        % ǰ�ٷ�֮������Ȥ����
        interestNum=min(ceil(totalInterestNum*interestPercent),totalInterestNum);
              
        % ����ÿ����Ȥ�漰����item��
        totalItemNum=0;  % �û��ܵĿ�����item��
        tempItemNum=0;   % ǰ�ٷ�֮������Ȥ�������û��Ŀ�����item����     
        
        tx1=find(userRatingMatrix(j,:)>0);
        totalItemNum=length(tx1);
           
        for k=1:interestNum
            itemInterestCircle=itemInterestCircleCell{interestWeight(k,1)};     
            % �û�������item�������ڸ���Ȥ����Ŀ
            intersectSet=intersect(tx1,itemInterestCircle);
            intersectNum=length(intersectSet);
            tempItemNum=tempItemNum+intersectNum;
        end

        % ������û�ǰ�ٷ�֮������Ȥ�漰����item����������ܵ�item�İٷֱ�
        tempPercentWeight=tempItemNum/totalItemNum;
        percentWeight=percentWeight+tempPercentWeight;
    end
    percentWeightList(i)=percentWeight/userCount;
end 

plot(percentList,percentWeightList);

