function dataCell = matrix2cell(dataMat)

% ��R��W�Ⱦ���ת���� cell ����parfor����
% ÿ��cell �洢mat�ж�Ӧ�е����ݣ���һ��������
dataCell = cell(size(dataMat,1),1);

for i=1:size(dataMat,1)
    vec=dataMat(i,:);
    dataCell{i}=vec;  
end



end