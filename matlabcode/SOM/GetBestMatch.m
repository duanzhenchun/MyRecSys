function neuroID=GetBestMatch(inputData,neuroMatrix)
% ��ȡ��input�����Ƶ���Ԫ
% ������Ԫ�ı��
neuroCount=size(neuroMatrix,2);

min_index=-1;
min_dist=inf;

for i = 1 :neuroCount
    tempneuro=neuroMatrix(:,i);
    tempindex=i;
    tempdist=GetDistance(inputData,tempneuro);
    if tempdist<min_dist
        min_dist=tempdist;
        min_index=tempindex;
    end
end

neuroID=min_index;


end