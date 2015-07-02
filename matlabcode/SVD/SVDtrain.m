clear;
tic;

% ѵ��SVDģ�ͣ�ѵ����ɺ󣬽��䱣�����ļ���
% lr ѧϰ�ٶȣ���ʱδ�ݼ�
% regul ���򻯲���

trainSetFileName='..\..\..\data\movielens\commondata\trainSet1.txt';
testSetFileName='..\..\..\data\movielens\commondata\testSet1.txt';
saveModelFileName='..\..\..\data\movielens\svddata\svdModel11.mat'; %ѵ����ɺ�ģ��Ҫ������ļ���

%% *******��ʼ��*******************
trainSet= load(trainSetFileName);
testSet=load(testSetFileName);

% ������ʼ��
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

% ����������ʼ��
avgRating=sum(trainRating)/trainCount;
bu=zeros(userCount,1);
bi=zeros(itemCount,1);
pu=rand(userCount,factorNum)/sqrt(factorNum);
qi=rand(itemCount,factorNum)/sqrt(factorNum);

rmseList=zeros(iterStep,1);

fprintf('start training....\n');
% ��ʼ����
for i=1:iterStep
    for j=1:trainCount     
        randIdx=randi(trainCount);% ���ѡ����
       	traincase=trainSet(randIdx,:);
        
        % ****����Ҫ��*****
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

% ѵ����ɺ󣬱��浽�ļ���
save(saveModelFileName,'avgRating','bu','bi','pu','qi','iterStep','factorNum');

toc;

