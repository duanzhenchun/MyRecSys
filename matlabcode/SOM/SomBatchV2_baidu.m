function [neuroMatrix,bmus]=SomBatchV2_baidu(data,height,width,iter)

% somBatch v2.0 增强版，速度更快！

%% *****************初始化*****************************
dataNum=size(data,2);
dim=size(data,1);  
neuroNum=height*width;
% 初始化时 取随机值,区间[a,b], 横轴是属性个数，纵轴是神经元的编号
b=max(max(data));
a=min(min(data));
neuroMatrix=a+(b-a).*rand(dim,neuroNum);
% neuroMatrix=rand(dim,neuroNum);

% 记录神经元的坐标
neuroCoordCell=cell(1,neuroNum);
for i=1:height
    for j=1:width
        neuroCoordCell{(i-1)*width+j}=[j i];
    end
end

% 神经元之间的距离矩阵
Ud=zeros(neuroNum,neuroNum);
for i=1:neuroNum
    for j=1:neuroNum
        Ud(i,j)=GetNeuroDistance(i,j,neuroCoordCell);
    end
end



%% ***********************训练*******************************
% batch train...

radius_init=floor(max(height,width)/2);
radius_decayconst=iter/log(radius_init);
radius=radius_init;

fprintf('begin batch train...');

% 记录每个input所归属的神经元ID, best match unit
bmus=zeros(dataNum,1);

% 计算常量
dConst=ones(neuroNum,dim)*data.^2;
start=clock;
quan_error=zeros(iter,1);
printedbytes = 0;

for t=1:iter
%     fprintf('iter step %d \n',t);   
    Dist=neuroMatrix'.^2*ones(dim,dataNum)-2*neuroMatrix'*data+dConst;
    [mindist,bmus]=min(Dist);
    
   % matrix Hcj,i     
    H=exp((-1*Ud.^2)/(2*radius^2)).*(Ud<=radius);
    Hi=H(bmus,:);
    S=data*Hi;
    
    A=repmat(sum(Hi,1),dim,1);    
    nonzero=find(A>0);   
    neuroMatrix(nonzero)=S(nonzero)./A(nonzero);    
    
    %plot
%     quan_error(t)=mean(sqrt(mindist));
    quan_error(t) = 0 ;
    printedbytes = trackplot(start,t,quan_error,printedbytes); 
    
    % update parameters
    radius_decayrate=exp(-t/radius_decayconst);
    radius=radius_init*radius_decayrate;
    
end

% % 记录每个输入点所属的类，找到它的 best match
% figure(2);
% plot(data(1,:),data(2,:),'go');

% hold on ;
% plot(neuroMatrix(1,:),neuroMatrix(2,:),'ro');

fprintf('the converged quan_error is %f \n ',quan_error(end));


end
