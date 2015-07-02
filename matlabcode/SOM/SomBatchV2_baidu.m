function [neuroMatrix,bmus]=SomBatchV2_baidu(data,height,width,iter)

% somBatch v2.0 ��ǿ�棬�ٶȸ��죡

%% *****************��ʼ��*****************************
dataNum=size(data,2);
dim=size(data,1);  
neuroNum=height*width;
% ��ʼ��ʱ ȡ���ֵ,����[a,b], ���������Ը�������������Ԫ�ı��
b=max(max(data));
a=min(min(data));
neuroMatrix=a+(b-a).*rand(dim,neuroNum);
% neuroMatrix=rand(dim,neuroNum);

% ��¼��Ԫ������
neuroCoordCell=cell(1,neuroNum);
for i=1:height
    for j=1:width
        neuroCoordCell{(i-1)*width+j}=[j i];
    end
end

% ��Ԫ֮��ľ������
Ud=zeros(neuroNum,neuroNum);
for i=1:neuroNum
    for j=1:neuroNum
        Ud(i,j)=GetNeuroDistance(i,j,neuroCoordCell);
    end
end



%% ***********************ѵ��*******************************
% batch train...

radius_init=floor(max(height,width)/2);
radius_decayconst=iter/log(radius_init);
radius=radius_init;

fprintf('begin batch train...');

% ��¼ÿ��input����������ԪID, best match unit
bmus=zeros(dataNum,1);

% ���㳣��
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

% % ��¼ÿ��������������࣬�ҵ����� best match
% figure(2);
% plot(data(1,:),data(2,:),'go');

% hold on ;
% plot(neuroMatrix(1,:),neuroMatrix(2,:),'ro');

fprintf('the converged quan_error is %f \n ',quan_error(end));


end
