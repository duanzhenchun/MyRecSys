function avgUserEvaluationByLevel=EvaluationAnalysis(allUserEvaluation,levelNum)

% ��������level�û�������ָ������
% allUserEvaluation �洢ÿ���û�precision recall ���
% [user, precision,recall ,level ]  userָ�����ַ�����������ID

avgUserEvaluationByLevel=zeros(levelNum,4);
for i=1:size(avgUserEvaluationByLevel,1)
    level=i;
    idx=find(allUserEvaluation(:,4)==level);
    avgPrecision=sum(allUserEvaluation(idx,2))/length(idx);
    avgRecall=sum(allUserEvaluation(idx,3))/length(idx);
    avgF1=2*avgPrecision*avgRecall/(avgPrecision+avgRecall);
    avgUserEvaluationByLevel(i,1)=level;
    avgUserEvaluationByLevel(i,2)=avgPrecision;
    avgUserEvaluationByLevel(i,3)=avgRecall;
    avgUserEvaluationByLevel(i,4)=avgF1;
end





end