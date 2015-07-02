    
algorithm = sprintf('cfulf');
topKList = (10:10:50);
for k = 1:5
topK = topKList(k);
fprintf('current top K is %d \n',topK );
for version = 1:30
    fprintf('current version is %d \n',version );
    allUserRecInfoFile = sprintf('..\\..\\..\\result\\baidu\\%s\\allUserRecInfo%d.mat',algorithm,version);   
    userRatingMatrixFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\userRatingMatrix%d.mat',version);   
    trainSetFileName=sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
    coreUserFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\coreUserID.txt');
    
    load(allUserRecInfoFile,'allUserRecInfo');
    load(userRatingMatrixFileName,'userRatingMatrix');
    trainSet = load(trainSetFileName);
    coreUser = load(coreUserFileName);
    
    userData=coreUser;   
    itemData=trainSet(:,2);
    uniqUserData=unique(userData);
    uniqItemData=unique(itemData);
    userCount=length(uniqUserData);
    itemCount=length(uniqItemData);
          
    testUserCount = length(allUserRecInfo);
    allUserEvaluation=zeros(testUserCount,4);
    allUserFinalRecList=cell(testUserCount,1);

    % reconstruct 
    for i=1:testUserCount
        infoCell = allUserRecInfo{i};
        if isempty(infoCell)
            continue
        end
        testUser = infoCell{1};
        testUserID = infoCell{2};
        level = infoCell{3};
        testUserLikedItemList = infoCell{4};
        finalRecList = infoCell{5};    
        if length(finalRecList) < topK
            realTopK = length(finalRecList);
            topRecList = finalRecList(1:realTopK);
        else
            topRecList = finalRecList(1:topK);
        end
        if isempty(topRecList)
            hitList = [];
            % 计算单个用户的precision和recall
            precision = 0;
            recall = 0 ;
        else
            [hitList,iia,iib] = intersect(topRecList,testUserLikedItemList);
            % 计算单个用户的precision和recall
            precision=length(hitList)/topK;
            recall=length(hitList)/length(testUserLikedItemList);
        end
        allUserEvaluation(i,:)=[testUser,precision,recall,level];
        recListCell=cell(1,3);
        recListCell{1}=testUser;
        recListCell{2}= topRecList;
        recListCell{3} = hitList;
        allUserFinalRecList{i}=recListCell;
    end

     %　分析各个Level用户的 准确率 召回率 F1
     % avgUserEvaluationByLevel = EvaluationAnalysis(allUserEvaluation, levelNum);
    avgTwoEvaluation=OnlyTwoEvaluation(allUserEvaluation);


    % itemSimiFileName=sprintf('..\\..\\..\\data\\baidu\\ibcfdata\\itemSimiMatrix%d.mat',version);
    % load(itemSimiFileName,'itemSimiMatrix');
    % itemDistMatrix = 1 - itemSimiMatrix;
    % clear itemSimiMatrix
    % itemPopularity = GetItemPopularity(userRatingMatrix);
    % [coverage,avgILD,novelty]  =DiversityAnalysis(allUserFinalRecList,itemDistMatrix,itemPopularity,itemCount,userCount);
    % avgILD = avgILD/2; % range 变为 0-1
    % fprintf('coverage is %f, avgILD is %f,novelty is %f \n ',coverage,avgILD,novelty);
    % clear itemDistMatrix

    itemPopularity = GetItemPopularity(userRatingMatrix);
    [coverage,novelty] =  NewDiversityAnalysis(allUserFinalRecList,itemPopularity,itemCount,userCount);

    finalDiversityFileName=sprintf('..\\..\\..\\result\\baidu\\%s\\final_baidu_%s_diversity_topK%d.txt',algorithm,algorithm,topK);
    finalColdUserResultFileName = sprintf('..\\..\\..\\result\\baidu\\%s\\final_baidu_%s_colduser_topK%d.txt',algorithm,algorithm,topK);

    fid = fopen(finalDiversityFileName,'a');
    fprintf(fid,'%f\t%f\r\n',coverage,novelty);
    fclose(fid);

    fid = fopen(finalColdUserResultFileName,'a');
    fprintf(fid,'%f\t%f\t%f\r\n',avgTwoEvaluation(1,2),avgTwoEvaluation(1,3),avgTwoEvaluation(1,4));
    fclose(fid);

end
end

