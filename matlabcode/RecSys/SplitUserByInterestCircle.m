function interestCircleCell=SplitUserByInterestCircle(weight,interestCircleThreshold)
% ��ÿ���û��������ĳ����Ȥ��Ȩֵ����Ȩֵ���ڵ���һ����ֵʱ�����û����ֵ��Ǹ���
% ����һ��Ԫ�飬ÿһ��cell��ʾ����������Ȥ�ڵ��û�ID��weight
% ����ÿ��cell����Ȩֵ�Ľ�������

interestCircleNum=size(weight,1);
interestCircleCell=cell(interestCircleNum,1);

for i=1:interestCircleNum
    tempWeight=weight(i,:);
    idx=find(tempWeight>interestCircleThreshold);
    if ~isempty(idx)
        interestCircle=zeros(length(idx),2);
        interestCircle(:,1)=idx;  %user id
        interestCircle(:,2)=tempWeight(idx);
        interestCircle=-sortrows(-interestCircle,2); %��Ȩֵ��������
        interestCircleCell{i}=interestCircle;
    end
end


end