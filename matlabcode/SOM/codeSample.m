% �Ƚ��ҵ�som batch ��  toolbox��� batch


clear;
tic;



load simplecluster_dataset;
data=simpleclusterInputs;
% ���������Ų�
height=10;
weight=10;
iter=5000;

% *************************************** my som *********************************************

% [neuroMatrix,bmus]=SomBatchV2(data,height,weight,iter);
% db_index=GetDB_Index(data,neuroMatrix,bmus);
% fprintf('the db_index is %f \n',db_index);

% *******************************************************************************************


% *************************************** tool box*********************************************

radius_init=floor(min(height,weight)/2);
boxData=data';    % Ҫ���� dlen x dim
sMap = som_randinit(boxData,'msize', [weight height],'lattice','rect');

[sMap,sTrain]=som_batchtrain(sMap,boxData,'trainlen',iter,'radius_ini',radius_init,'radius_fin',1,'tracking',3,...
    'neigh','gaussian');

boxNeuroMatrix=sMap.codebook;   % len x dim 
dataNum=size(boxData,1);
boxInputClass=zeros(dataNum,1);
for i=1:dataNum
    inputData=boxData(i,:);
    bestMatchID=GetBestMatch(inputData',boxNeuroMatrix');  % ���涼�����м����
    boxInputClass(i)=bestMatchID;
end

db_index=GetDB_Index(data,boxNeuroMatrix',boxInputClass);
fprintf('the db_index is %f \n',db_index);


boxItemCell=SplitItemByInterestCircle(boxInputClass,size(boxNeuroMatrix,1));

% **************************************************************************************************



toc;