function interestCircleCell=SplitUserByInterestCircle3(weight,cutRate)
% ��ÿ���û��������ĳ����Ȥ��Ȩֵ����Ȩֵ���ڵ���һ����ֵʱ�����û����ֵ��Ǹ���
% ����һ��Ԫ�飬ÿһ��cell��ʾ����������Ȥ�ڵ��û�ID��weight
% ����ÿ��cell����Ȩֵ�Ľ�������

interestCircleNum=size(weight,1);
interestCircleCell=cell(interestCircleNum,1);

for i=1:interestCircleNum
    tempWeight=weight(i,:);
    idx=find(tempWeight>0);
    if ~isempty(idx)
        interestCircle=zeros(length(idx),2);
        interestCircle(:,1)=idx;  %user id
        interestCircle(:,2)=tempWeight(idx);
        interestCircle=-sortrows(-interestCircle,2); %��Ȩֵ��������
        peopleCount = round(length(idx) * cutRate); 
        interestCircleCell{i}=interestCircle(1:peopleCount,:);
    end
end


end