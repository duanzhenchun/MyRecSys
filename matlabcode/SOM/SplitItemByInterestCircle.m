function itermInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,interestCircleNum)
% ������item���ֵ���ͬ����
% ����cell��ÿ��cell��ʾһ����Ȥ�أ�����װ�Ż��ֵ��ôص�item
itermInterestCircleCell=cell(1,interestCircleNum);
for i=1:length(itemClassIndex)
    circleID=itemClassIndex(i);
    itermInterestCircleCell{circleID}=[itermInterestCircleCell{circleID} i];
end
end