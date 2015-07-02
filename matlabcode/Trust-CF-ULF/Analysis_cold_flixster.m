    
algorithm = sprintf('trustcfulf');
topK = 50;
fprintf('current top K is %d \n',topK );
for version = 1:30
    fprintf('current version is %d \n',version );
    allUserRecInfoFile = sprintf('..\\..\\..\\result\\flixster\\%s\\allUserRecInfo%d.mat',algorithm,version);   
    userRatingMatrixFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\userRatingMatrix%d.mat',version);   
    trainSetFileName=sprintf('..\\..\\..\\data\\flixster\\commondata\\trainSet%d.txt',version);
    coreUserFileName = sprintf('..\\..\\..\\data\\flixster\\commondata\\coreUserID%d.txt',version);
    
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
    allUserEvaluation = zeros(testUserCount,4);
    allUserFinalRecList = cell(testUserCount,1);

    % reconstruct 
    for i=1:testUserCount
        infoCell = allUserRecInfo{i};
        if isempty(infoCell)
            continue
        end
        testUser = infoCell{1};
        testUserID = infoCell{2};
        level = infoCell{3};
        if level ~= 1
            continue
        end
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


    itemPopularity = GetItemPopularity(userRatingMatrix);
    [coverage,novelty] =  NewDiversityAnalysis(allUserFinalRecList,itemPopularity,itemCount,userCount);

    finalDiversityFileName=sprintf('..\\..\\..\\result\\flixster\\%s\\final_flixster_%s_colduser_diversity_topK%d.txt',algorithm,algorithm,topK);
   
    fid = fopen(finalDiversityFileName,'a');
    fprintf(fid,'%f\t%f\r\n',coverage,novelty);
    fclose(fid);

  

end


