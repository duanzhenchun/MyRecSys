clear;
tic

cfulfFile = sprintf('..\\..\\..\\result\\baidu\\cfulf\\allUserFinalRecList.mat');
puretrustFile = sprintf('..\\..\\..\\result\\baidu\\puretrust\\allUserFinalRecList.mat');
trustcfulfFile = sprintf('..\\..\\..\\result\\baidu\\trustcfulf\\allUserFinalRecList.mat');
pbmimFile =  sprintf('..\\..\\..\\result\\baidu\\som\\pbmim\\allUserFinalRecList.mat');
snmimFile =  sprintf('..\\..\\..\\result\\baidu\\som\\snmim\\allUserFinalRecList.mat');
cmimFile = sprintf('..\\..\\..\\result\\baidu\\som\\cmim\\allUserFinalRecList.mat');


load(cfulfFile,'allUserFinalRecList')
cfulfInfo = allUserFinalRecList;

load(puretrustFile,'allUserFinalRecList')
puretrustInfo = allUserFinalRecList;

load(trustcfulfFile,'allUserFinalRecList')
trustcfulfInfo = allUserFinalRecList;

load(pbmimFile,'allUserFinalRecList')
pbmimInfo = allUserFinalRecList;

load(snmimFile,'allUserFinalRecList')
snmimInfo = allUserFinalRecList;

load(cmimFile,'allUserFinalRecList')
cmimInfo = allUserFinalRecList;


avgdiv = relativeDiversityAnalysis(cmimInfo,cfulfInfo );
fprintf('the avg diversity is %f \n',avgdiv)












toc