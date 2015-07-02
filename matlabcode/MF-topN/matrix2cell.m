function dataCell = matrix2cell(dataMat)

% 将R，W等矩阵转换成 cell 方便parfor调用
% 每个cell 存储mat中对应行的数据，是一个行向量
dataCell = cell(size(dataMat,1),1);

for i=1:size(dataMat,1)
    vec=dataMat(i,:);
    dataCell{i}=vec;  
end



end