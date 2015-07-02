 clear;
 clc;
 
% baidu best alpha is 0.9

alpha0 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.0.txt'));
alpha1 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.1.txt'));
alpha2 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.2.txt'));
alpha3 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.3.txt'));
alpha4 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.4.txt'));
alpha5 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.5.txt'));
alpha6 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.6.txt'));
alpha7 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.7.txt'));
alpha8 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.8.txt'));
alpha9 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha0.9.txt'));
alpha10 = load(sprintf('..\\..\\..\\result\\baidu\\som\\cmim_alpha\\final_baidu_cmim_prf_top50_alpha1.0.txt'));





col = 3;
alpha0_current = alpha0(:,col);
alpha1_current = alpha1(:,col);
alpha2_current = alpha2(:,col);
alpha3_current = alpha3(:,col);
alpha4_current = alpha4(:,col);
alpha5_current = alpha5(:,col);
alpha6_current = alpha6(:,col);
alpha7_current = alpha7(:,col);
alpha8_current = alpha8(:,col);
alpha9_current = alpha9(:,col);
alpha10_current = alpha10(:,col);

mat = [alpha9_current alpha0_current alpha1_current alpha2_current alpha3_current ...
       alpha4_current alpha5_current alpha6_current alpha7_current alpha8_current  alpha10_current];

meanmat = mean(mat)'
stdmat = std(mat)'


[h1,p1] = ttest(alpha9_current,alpha0_current,0.05,'right');
[h2,p2] = ttest(alpha9_current,alpha1_current,0.05,'right');
[h3,p3] = ttest(alpha9_current,alpha2_current,0.05,'right');
[h4,p4] = ttest(alpha9_current,alpha3_current,0.05,'right');
[h5,p5] = ttest(alpha9_current,alpha4_current,0.05,'right');
[h6,p6] = ttest(alpha9_current,alpha5_current,0.05,'right');
[h7,p7] = ttest(alpha9_current,alpha6_current,0.05,'right');
[h8,p8] = ttest(alpha9_current,alpha7_current,0.05,'right');
[h9,p9] = ttest(alpha9_current,alpha8_current,0.05,'right');
[h10,p10] = ttest(alpha9_current,alpha10_current,0.05,'right');



hmat = [h1;h2;h3;h4;h5;h6;h7;h8;h9;h10]
pmat = [p1;p2;p3;p4;p5;p6;p7;p8;p9;p10]

