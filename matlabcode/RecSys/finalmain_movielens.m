clear;
tic;

%% ���һ�� ������

%% **************���ļ�����ʹ洢��Ŀ¼���������趨*********************************
date='10.27';

for version=1:5
% version=1;   % �ڼ������ݼ�
fprintf('--------------- the current version is %d ----------------- \n',version);

% heightList= [2,4,8,8,10,12];
% widthList= [5,5,5,10,10,10];

% for it=1:6
% height=heightList(it);
% width=widthList(it);

width=5;
height=4;

fprintf('current map is %d x %d \n', width,height);

ratingSomFileName=sprintf('..\\..\\..\\data\\movielens\\somdata\\movielens_%dx%d_som%d.mat',width,height,version); 
testSetFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\testSet%d.txt',version);
saveRecListFileName=sprintf('..\\..\\..\\data\\movielens\\somdata\\recList\\reclist%d.mat',version);
weightFileName = sprintf('..\\..\\..\\data\\movielens\\commondata\\weight_%dx%d_%d.mat',width,height,version);
userRatingMatrixFileName=sprintf('..\\..\\..\\data\\movielens\\commondata\\userRatingMatrix%d.mat',version);

%% ******************** ����֮ǰ�����õ����� **********************************

load(ratingSomFileName, 'uniqUserData', 'uniqItemData', 'itemClassIndex');
load(userRatingMatrixFileName,'userRatingMatrix');
testSet = load(testSetFileName);
load(weightFileName,'local_weight','global_weight');

%% ******************���г�ʼ��***************************

userCount=length(uniqUserData);
itemCount=length(uniqItemData);
testUserData=testSet(:,1);
uniqTestUserData=unique(testUserData);
testUserCount=length(uniqTestUserData);
interestCount=size(local_weight,1);


% һЩ��Ϊ�̶��Ĳ���
likeThreshold=4;   % �ж��û��Ƿ�ϲ��һ��item����ֵ��Ҫ������
recThreshold=0;  % ����������Ȥ�����Ƽ�ʱ����ÿ����ȤȦ�Ԥ������Ҫ���������ֵ�Żᱻ�Ƽ�
interestCircleThreshold=0.0;  % ������Ȥ�û�����ֵ���������ֵ���û����뵽��ȤȦ
majorInterestThreshold=0.00;  % �����Ƿ�����Ҫ��Ȥ
beta = 0.10;
fprintf('current beta  is %f \n',beta)


% �������û����ֵ���ͬ��Ȥ����ȥ����ͬ��֮���û������ص�
% userInterestCircleCell=SplitUserByInterestCircle3(global_weight,cutRate);
userInterestCircleCell=SplitUserByInterestCircle(global_weight,interestCircleThreshold);

% ������item���ֵ���ͬ��Ȥ���У���֮��item���ص�
itemInterestCircleCell=SplitItemByInterestCircle(itemClassIndex,interestCount);

% ��������û�ƽ�����
userAvgRating = GetAllUserAvgRating(userRatingMatrix);

%% **** ��������� *******

%% ***************�������ü�һЩ��ʼ������*********************
topKList=(10:10:100);

recListLengthRecord=[]; % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
 % ��¼��ÿ���û����Ƽ��б�
allUserFinalRecList=cell(testUserCount,1);  

allUserRecInfo = cell(testUserCount,1);  

totalPrecision = zeros(1,10);
totalRecall = zeros(1,10);
totalCount=0; %��Ϊ������precision,recall ,f1�ķ�ĸ
notCount = 0; % ���Լ�����û�����ִ��ڵ���4��

fprintf('start the iteration ... \n')
userRatingMatrix = sparse(userRatingMatrix);
%% *******************��ʼ����************************
parfor i=1:testUserCount
    the20num=round(0.2*testUserCount);
    if mod(i,the20num)==0
        disp ('20%');
    end
    %% ***********��ÿ��Ŀ���û�����һЩ��ʼ��****************
    
    % ���Ƽ��û�ID
    testUser=uniqTestUserData(i);
    % ��ѵ�����е�uniqUserData�� testuser��Ӧ��ID
    testUserID=find(uniqUserData == testUser);
 
  
    %% *********************************������һ����ȡ��Ŀ���û����Ƽ��б�*********************
    
    %% ***********ȡ��Ŀ���û�����������Ϣ�õ�����Ȥ��Ȩ��************
    
    ratingInterestWeight=zeros(interestCount,2);
    ratingInterestWeight(:,1)=(1:interestCount);
    ratingInterestWeight(:,2)=local_weight(:,testUserID);
   
    totalGlobalInterest = global_weight(:,testUserID);
     
    % ѡ�������ֵ����Ȥ,�����Ĳ�ȥ����ֻ�Ǹ�ֵΪ0�����������
    % ########### rating interest ��ʱ������########################
%     idx=find(ratingInterestWeight(:,2) < majorInterestThreshold);
%     ratingInterestWeight(idx,2)=0;

    % ��һ��
    totalWeight1 = sum(ratingInterestWeight(:,2));
    if totalWeight1>0
        ratingInterestWeight(:,2)=ratingInterestWeight(:,2)/totalWeight1;
    end
    
    %% ***********ȡ��Ŀ���û������罻��Ϣ�õ�����Ȥ��Ȩ��*************
    
    
    %% ***************��Ȥ�ϲ�*************************
    mixedInterestWeight=zeros(interestCount,2);
    mixedInterestWeight(:,1)=(1:interestCount);
    
    mixedInterestWeight(:,2)=ratingInterestWeight(:,2);


    % ȥ��Ϊ0����Ȥ
    tx0=find(mixedInterestWeight(:,2)>0);
    mixedInterestWeight=mixedInterestWeight(tx0,:);
    % ��������
    mixedInterestWeight=-sortrows(-mixedInterestWeight,2);     
       
    % ��������Ȩ�صĺ�
    totalWeight=sum(mixedInterestWeight(:,2));
    totalInterestRecList=[];
    
    maxInterest = 15;
    simpleCount =0;
    %% ************* ����Ŀ���û�ÿһ����Ȥ����һ���Ƽ��б���ȥ���û��Ѿ������� *********************
    for j=1:size(mixedInterestWeight,1)      
        if simpleCount>maxInterest
            continue;
        end
        simpleCount = simpleCount+1;
        
        % �����Ȩ��,����ٺϲ�����Ȥ���ϣ�Ҫ����ȥ
        tempWeight = mixedInterestWeight(j,2)/totalWeight;
        % ��ȡ�ڸ���ȤȦ�������
        userInterestCircle = userInterestCircleCell{mixedInterestWeight(j,1)};
        
        interestNo = mixedInterestWeight(j,1);
        globalPrefer = totalGlobalInterest(interestNo);
        
        % ע����ȤȦΪ�յ����
        if isempty(userInterestCircle)
            continue
        end
        % ����ȤС����ȥ���Լ�
        idx1=find(userInterestCircle(:,1) == testUserID);
        userInterestCircle(idx1,:)=[];
        % ��ȡ���ֵ�����ȤȦ��item
        itemInterestCircle=itemInterestCircleCell{mixedInterestWeight(j,1)};
        if isempty(itemInterestCircle)
            continue
        end
        % *****������Ȥ�����Ƽ�******     
        % ################### ע����ʱ����Ԥ�����ֵĴ�С������ ##########################
        
        %  ##   huiyi ���� ####
        
        interestRecList = GetRecListByInterestCircle2_huiyi(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,globalPrefer,beta);
%         interestRecList = GetRecListByInterestCircle2(testUserID,userInterestCircle,itemInterestCircle,userRatingMatrix,globalPrefer,beta);                           
       
        % ����Ҫ�������Ȧ�ӵ����Ȩ��
        interestRecList(:,2)=interestRecList(:,2)*tempWeight;
               
        % �����һ����ע������item��������Ȥ���ID����ʱ���ٸĻ���
        completeInterestRecList = zeros(size(interestRecList,1),3);
        completeInterestRecList(:,1:2) = interestRecList(:,1:2);
        completeInterestRecList(:,3) = mixedInterestWeight(j,1);
        % ���ܸ�����ȤȦ�ӵĽ��
        
        totalInterestRecList=[totalInterestRecList; completeInterestRecList];
    end   
    
     % ��¼һ��ÿ���û����Ƽ��б�ĳ��ȣ��������topK
    recListLengthRecord=[recListLengthRecord; [testUser size(totalInterestRecList,1)]];
    
   finalRecList = cell(10,1);
    % �Ժϲ�����Ƽ��б���ָߵͽ������򣬽�������
    if ~isempty(totalInterestRecList)
        totalInterestRecList=-sortrows(-totalInterestRecList,2);
         % ȥ��testUser�Ѿ�������
        watchedItemList=find(userRatingMatrix(testUserID,:)>0);
        [c,ia]=intersect(totalInterestRecList(:,1),watchedItemList);
        totalInterestRecList(ia,:)=[];
         % ��topK�����ã������Ͳ�����
         
        for m = 1:10
            if length(totalInterestRecList(:,1))<topKList(m)
                realTopK = length(totalInterestRecList(:,1));
                finalRecList{m}= totalInterestRecList(1:realTopK,1);
            else
                finalRecList{m} = totalInterestRecList(1:topKList(m),1);
            end
        end
        
    end
       
    
    %% **********************************�����ڶ�����ȡ�ò��Լ���Ŀ���û�ϲ����item�б�***********************
    % �����ִ���likeThreshold��ʾϲ��
    tempIndex=find(testSet(:,1)==testUser & testSet(:,3)>=likeThreshold);
    tempItemSet=testSet(tempIndex,2);
    
    [commonItem,IA,IB]=intersect(uniqItemData,tempItemSet);
    testUserLikedItemList=IA;
        
    if isempty(testUserLikedItemList)
        % ���Լ��û���û�����ִ���3��item���򲻿�������û����Ƽ��������Ƽ�
        notCount = notCount+1;
        continue;       
    end
    
    %% **************************************�����������������Ƽ�Ч��****************************************
    % ���Ƽ��б�Ͳ��Լ����û�ϲ����itemȡ��������Ϊhit����
    precisionList= [];
    recallList = [];
    for m = 1:10
        if isempty(finalRecList{m})
            hitList = [];
            % ���㵥���û���precision��recall
            precision = 0;
            recall = 0 ;
        else
            [hitList,iia,iib] = intersect(finalRecList{m},testUserLikedItemList);
            % ���㵥���û���precision��recall
            precision=length(hitList)/topKList(m);
            recall=length(hitList)/length(testUserLikedItemList);
        end
        if isnan(recall) || isnan(precision)
            disp('there is something wrong with the recall or the precision');
        end
        precisionList = [precisionList precision];
        recallList = [recallList recall];     
    end
    
    totalPrecision = totalPrecision + precisionList;
    totalRecall = totalRecall + recallList;
        
    % ��¼ÿ���û������յ��Ƽ��б�      

    recListCell=cell(1,2);
    recListCell{1}=testUser;
    recListCell{2}=finalRecList{5};
    allUserFinalRecList{i}=recListCell;
             
    % �ܵ����ģ�����+1�������Ϊ��ĸ
    totalCount=totalCount+1;
    
    
end

%% #####################����ָ��###########################

avgPrecision=totalPrecision/totalCount;
avgRecall=totalRecall/totalCount;
avgF1=2*avgPrecision.*avgRecall./(avgPrecision+avgRecall);

itemSimiFileName = sprintf('..\\..\\..\\data\\movielens\\ibcfdata\\itemSimiMatrix_cos%d.mat',version);
load(itemSimiFileName,'itemSimiMatrix');
itemDistMatrix = 1 - itemSimiMatrix;
clear itemSimiMatrix;
itemPopularity = GetItemPopularity(userRatingMatrix);
[coverage,avgILD,novelty] = DiversityAnalysis(allUserFinalRecList,itemDistMatrix,itemPopularity,itemCount,userCount);
avgILD = avgILD/2;
fprintf('coverage is %f, avgILD is %f,novelty is %f \n ',coverage,avgILD,novelty);
clear itemDistMatrix;

% **********final ʵ���� ***************
for m =1:5
    topK = topKList(m);
    finalResultFileName=sprintf('..\\..\\..\\result\\movielens\\som\\pbmim\\final_movielens_pbmim_prf_top%d.txt',topK);
%     finalResultFileName=sprintf('..\\..\\..\\result\\movielens\\som\\pbmim\\final_movielens_pbmim_prf_top%d_beta%1.2f_neighbor%d.txt',topK,beta,50);
    fid = fopen(finalResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgPrecision(m),avgRecall(m),avgF1(m));
    fclose(fid);
end

finalDiversityFileName = sprintf('..\\..\\..\\result\\movielens\\som\\pbmim\\final_movielens_pbmim_diversity.txt');

fid = fopen(finalDiversityFileName,'a');
fprintf(fid,'%f\t%f\t%f\r\n',coverage,avgILD,novelty);
fclose(fid);



% end
end



toc;

