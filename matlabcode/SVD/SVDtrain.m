clear;
tic;

% 训练SVD模型，训练完成后，将其保存在文件中
% lr 学习速度，暂时未递减
% regul 正则化参数

trainSetFileName='..\..\..\data\movielens\commondata\trainSet1.txt';
testSetFileName='..\..\..\data\movielens\commondata\testSet1.txt';
saveModelFileName='..\..\..\data\movielens\svddata\svdModel11.mat'; %训练完成后，模型要保存的文件名

%% *******初始化*******************
trainSet= load(trainSetFileName);
testSet=load(testSetFileName);

% 参数初始化
lr=0.05;
regul=0.1;
iterStep=50;
factorNum=50;

userData=trainSet(:,1);
itemData=trainSet(:,2);
uniqUserData=unique(userData);
uniqItemData=unique(itemData);
userCount=length(uniqUserData);
itemCount=length(uniqItemData);

testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);

trainRating=trainSet(:,3);
trainCount=size(trainSet,1);

minRating=min(trainRating);
maxRating=max(trainRating);

% 各个特征初始化
avgRating=sum(trainRating)/trainCount;
bu=zeros(userCount,1);
bi=zeros(itemCount,1);
pu=rand(userCount,factorNum)/sqrt(factorNum);
qi=rand(itemCount,factorNum)/sqrt(factorNum);

rmseList=zeros(iterStep,1);

fprintf('start training....\n');
% 开始迭代
for i=1:iterStep
    for j=1:trainCount     
        randIdx=randi(trainCount);% 随机选样本
       	traincase=trainSet(randIdx,:);
        
        % ****将来要改*****
        user=traincase(1);
        uid=find(uniqUserData==user);
        item=traincase(2);
        iid=find(uniqItemData==item);
        % *******************       
        rating=traincase(3);
        
        predict=avgRating+bu(uid)+bi(iid)+pu(uid,:)*qi(iid,:)';     
        
        if predict<minRating
            predict=minRating;
        elseif predict>maxRating
                predict=maxRating;
        end

        eui=rating-predict;  % error       
        % ****  update ******
        bu(uid)=bu(uid)-lr*(eui+regul*bu(uid));
        bi(iid)=bi(iid)-lr*(eui+regul*bi(iid));
        unUpdataedPu=pu;
        pu(uid,:)=pu(uid,:)-lr*(-eui*qi(iid,:)+regul*pu(uid,:));
        qi(iid,:)=qi(iid,:)-lr*(-eui*unUpdataedPu(uid,:)+regul*qi(iid,:));       
    end
    rmse=GetRMSE(avgRating,bu,bi,pu,qi,uniqUserData,uniqItemData,trainSet);        
    if i > 10
        if rmse > rmseList(i-1)
            fprintf(' the rmse is %f \n',rmse);
            break
        end
    end
        
    rmseList(i)=rmse;
   
    fprintf('the %d step, the rmse is %f \n',i,rmse);
%     plot(1:i,rmseList(1:i),(i+1):iterStep,rmseList(i+1:end));
%     title('rmse after each epoch');
%     drawnow;
end


plot((1:iterStep),rmseList);

% 训练完成后，保存到文件中
save(saveModelFileName,'avgRating','bu','bi','pu','qi','iterStep','factorNum');

toc;

