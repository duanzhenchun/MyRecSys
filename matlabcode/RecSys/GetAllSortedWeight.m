function allSortedWeightCell=GetAllSortedWeight(weight)

% ���ÿ��user,����weight����������
% ��󷵻�һ��Ԫ�飬��¼ÿ��user����Ȥ����1��Ϊ��Ȥ�ı�ţ���2��Ϊ���û��Դ���Ȥ��ƫ�ó̶�

userNum=size(weight,2);
interestNum=size(weight,1);
allSortedWeightCell=cell(1,userNum);
for i=1:userNum
    % ��һ�д���ţ��ڶ��д�weightֵ
    interestData=zeros(interestNum,2);
    interestData(:,1)=(1:interestNum);
    interestData(:,2)=weight(:,i);
    % ����������
    sortedInterestData=-sortrows(-interestData,2);
    allSortedWeightCell{i}=sortedInterestData;
end
end