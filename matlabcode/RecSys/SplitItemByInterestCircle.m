function itermInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,interestCircleNum)
% ������item���ֵ���ͬ����
% ����cell��ÿ��cell��ʾһ����Ȥ�أ�����װ�Ż��ֵ��ôص�item
itermInterestCircleCell=cell(interestCircleNum,1);
for i=1:interestCircleNum
    circleID=i;
    itemSet=find(itemClassIndex==circleID);
    itermInterestCircleCell{circleID}=itemSet;   
end

end