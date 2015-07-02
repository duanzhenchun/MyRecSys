function avgTwoEvaluation=OnlyTwoEvaluation(allUserEvaluation)

% ��������level�û�������ָ������
% allUserEvaluation �洢ÿ���û�precision recall ���
% [user, precision,recall ,level ]  userָ�����ַ�����������ID

avgTwoEvaluation=zeros(2,4);

%% for level 1
idx1=find(allUserEvaluation(:,4)==1);
avgPrecision=sum(allUserEvaluation(idx1,2))/length(idx1);
avgRecall=sum(allUserEvaluation(idx1,3))/length(idx1);
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
avgTwoEvaluation(1,1)=1;
avgTwoEvaluation(1,2)=avgPrecision;
avgTwoEvaluation(1,3)=avgRecall;
avgTwoEvaluation(1,4)=avgF1;


%% for level 2 ~ 6
idx2=find(allUserEvaluation(:,4)~=1 & allUserEvaluation(:,4)~=0);
avgPrecision=sum(allUserEvaluation(idx2,2))/length(idx2);
avgRecall=sum(allUserEvaluation(idx2,3))/length(idx2);
avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
avgTwoEvaluation(2,1)=2;
avgTwoEvaluation(2,2)=avgPrecision;
avgTwoEvaluation(2,3)=avgRecall;
avgTwoEvaluation(2,4)=avgF1;

end




