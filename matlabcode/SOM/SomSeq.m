clear;
clc;
tic
%% 导入训练数据
% load simplecluster_dataset;
% data=simpleclusterInputs;
version=1;
height=10;
width=10;
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userRatingMatrix%d.mat',version);
load(userRatingMatrixFileName,'userRatingMatrix');
userRatingMatrix = userRatingMatrix(1:5000,1:5000);
data = userRatingMatrix;
dataNum=size(data,2);

%% 初始化
neuroDim=size(data,1);
% 按长方形排布
% height=8;
% width=8;
neuroNum=height*width;
% 初始化时 取随机值,区间[a,b], 横轴是属性个数，纵轴是神经元的编号
b=max(max(data));
a=min(min(data));
neuroMatrix=a+(b-a).*rand(neuroDim,neuroNum);

% 记录神经元的坐标
neuroCoordCell=cell(1,neuroNum);
for i=1:height
    for j=1:width
        neuroCoordCell{(i-1)*width+j}=[j i];
    end
end

% 神经元之间的距离矩阵
neuroDistMatrix=zeros(neuroNum,neuroNum);
for i=1:neuroNum
    for j=1:neuroNum
        neuroDistMatrix(i,j)=GetNeuroDistance(i,j,neuroCoordCell);
    end
end

% quality measure record
quan_error_collector=[];
topo_error_collector=[];


% 记录每个input所归属的神经元ID
inputClass=zeros(dataNum,1);

%% 训练
% rought train...
rough_iter=50;
radius_init=floor(width/2);
rough_lr=0.5;  % learning rate
radius_decayconst=rough_iter/log(radius_init);
radius=radius_init;

fprintf('begin rough tune train...');

for k1=1:rough_iter
    disp(k1)    
    influenceMatrix=exp((-1*neuroDistMatrix.^2)/(2*radius^2)); 
    for i=1:dataNum
        inputData=data(:,i);
        bestMatchID=GetBestMatch(inputData,neuroMatrix);
        inputClass(i)=bestMatchID;  
                                
        % 找到邻域内的neuro,即要更新的neuro
        neighborNeuroID=find(neuroDistMatrix(bestMatchID,:)<=radius);
        influenceVector=influenceMatrix(bestMatchID,neighborNeuroID);
        dim=size(neuroMatrix,1);
        repInfluenceVector=repmat(influenceVector,dim,1);
        repInputData=repmat(inputData,1,length(neighborNeuroID));
        neuroMatrix(:,neighborNeuroID)=neuroMatrix(:,neighborNeuroID)+(rough_lr*repInfluenceVector).*(repInputData-neuroMatrix(:,neighborNeuroID));
        
        
        
%         for j=1:neuroNum
%             neuroDist=GetNeuroDistance(bestMatchID,j,neuroCoordCell);
%             if neuroDist<=radius
%                 influence=exp((-1*neuroDist^2)/(2*radius^2));
%                 % learning
%                 neuroMatrix(:,j)=neuroMatrix(:,j)+influence*rough_lr*(inputData-neuroMatrix(:,j));
% %                 disp(influence*rough_lr*(inputData-neuroMatrix(:,j)))
%             end
%         end 
        
    end
    % update parameters
    radius_decayrate=exp(-k1/radius_decayconst);
    radius=radius_init*radius_decayrate;
%     rough_lr=rough_lr*exp(-k1/rough_iter);
    [quan_error topo_error ]=GetQualityMeasure(data,neuroMatrix,neuroCoordCell);
    quan_error_collector=[quan_error_collector quan_error];
    topo_error_collector=[topo_error_collector topo_error];
    
end


% fine tune train...
fprintf('begin fine tune train...');
fine_iter=50;
fine_lr=0.5;
% radius=1;
for k2=1:fine_iter
    disp(k2)
    influenceMatrix=exp((-1*neuroDistMatrix.^2)/(2*radius^2)); 
    for i=1:dataNum
        inputData=data(:,i);
        bestMatchID=GetBestMatch(inputData,neuroMatrix);
        inputClass(i)=bestMatchID;
                              
        % 找到邻域内的neuro,即要更新的neuro
        neighborNeuroID=find(neuroDistMatrix(bestMatchID,:)<=radius);
        influenceVector=influenceMatrix(bestMatchID,neighborNeuroID);
        dim=size(neuroMatrix,1);
        repInfluenceVector=repmat(influenceVector,dim,1);
        repInputData=repmat(inputData,1,length(neighborNeuroID));
        neuroMatrix(:,neighborNeuroID)=neuroMatrix(:,neighborNeuroID)+(fine_lr*repInfluenceVector).*(repInputData-neuroMatrix(:,neighborNeuroID));
        
        
%         for j=1:neuroNum
%             neuroDist=GetNeuroDistance(bestMatchID,j,neuroCoordCell);
%             if neuroDist<=radius
%                 influence=exp((-1*neuroDist^2)/(2*radius^2));
% %                 disp(influence)
%                 % learning
%                 neuroMatrix(:,j)=neuroMatrix(:,j)+influence*fine_lr*(inputData-neuroMatrix(:,j));
% %                 disp(inputData-neuroMatrix(:,j))
% %                 disp(influence*fine_lr*(inputData-neuroMatrix(:,j)))
%             end
%         end
        
        
        
        
    end    
     % update parameters
%     fine_lr=fine_lr*exp(-k2/fine_iter);
    fine_lr=fine_lr*0.95;
    [quan_error topo_error]=GetQualityMeasure(data,neuroMatrix,neuroCoordCell);
    quan_error_collector=[quan_error_collector quan_error];
    topo_error_collector=[topo_error_collector topo_error];
end

% 记录每个输入点所属的类，找到它的 best match
toc

figure(1);
plot(data(1,:),data(2,:),'go');
hold on ;
plot(neuroMatrix(1,:),neuroMatrix(2,:),'ro');

figure(2);
plot((1:rough_iter+fine_iter),quan_error_collector);

figure(3);
plot((1:rough_iter+fine_iter),topo_error_collector);

%drawnow
