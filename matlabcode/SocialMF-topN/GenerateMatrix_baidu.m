clear;
tic;

% 生成 socialMF要用的 rating矩阵 和social 矩阵
version = 1;
trainSetFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\trainSet%d.txt',version);
socialFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\finalSocial.txt');

saveRatingFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\bigUserRatingMatrix%d.mat',version);
saveSocialFileName = sprintf('..\\..\\..\\data\\baidu\\commondata\\socialMatrix.mat');
saveUserFileName =  sprintf('..\\..\\..\\data\\baidu\\commondata\\bigUser.mat');

trainSet= load(trainSetFileName);
finalSocial = load(socialFileName);

userList = [ finalSocial(:,1);  finalSocial(:,2)];
bigUser = unique(userList);
userNum = length(bigUser);

uniqueItem = unique(trainSet(:,2));
itemNum = length(uniqueItem);

trainNum = size(trainSet,1);
uList = zeros(trainNum, 1);
iList = zeros(trainNum, 1);
rList = zeros(trainNum, 1);

fprintf('get rating data...\n')
parfor m=1:trainNum
    user = trainSet(m, 1);
    item = trainSet(m, 2);
    rating = trainSet(m, 3);
    uid = find(bigUser == user);
    iid = find(uniqueItem == item);
    uList(m) = single(uid);
    iList(m) = single(iid);
    rList(m) = single(rating);
end

socialNum = size(finalSocial,1);
u1List1 = zeros(socialNum, 1);
u2List1 = zeros(socialNum, 1);
sList1 = zeros(socialNum, 1);
u1List2 = zeros(socialNum, 1);
u2List2 = zeros(socialNum, 1);
sList2 = zeros(socialNum, 1);

fprintf('get social data...\n')
num20=round(socialNum*0.2);
parfor n = 1: socialNum
   if mod(n,num20)==0
       disp('20%...')
   end
   user1 = finalSocial(n, 1);
   user2 = finalSocial(n, 2);
   u1id = find(bigUser == user1);
   u2id = find(bigUser == user2);
   u1List1(n) = single(u1id);
   u2List1(n) = single(u2id);
   sList1(n) = single(1);
   u1List2(n) = single(u2id);
   u2List2(n) = single(u1id);
   sList2(n) = single(1);
end

u1List=[u1List1;u1List2];
u2List=[u2List1;u2List2];
sList=[sList1;sList2];

fprintf('generate matrix ...')
bigUserRatingMatrix = sparse(uList,iList,rList,userNum,itemNum);
oldSocialMatrix = sparse(u1List,u2List,sList,userNum,userNum);

% 去重
oldSocialMatrix(oldSocialMatrix>0) = 1;
linknum = sum(sum(oldSocialMatrix))/2;

% normalize
socialBase=sum(oldSocialMatrix,2);
[newU1List,newU2List,newSList] = find(oldSocialMatrix);
parfor m=1:length(newU1List)
   row =  newU1List(m);
   newSList(m) =  newSList(m)/socialBase(row);
end
socialMatrix = sparse(newU1List,newU2List,newSList,userNum,userNum);


save(saveRatingFileName,'bigUserRatingMatrix');
save(saveSocialFileName,'socialMatrix');
save(saveUserFileName,'bigUser');
toc;