function shortDistanceMatrix=FloydAlgorithm(adj_Matrix)
% floyd�㷨������һ���ڽӾ����и�����֮�����̾���
% ����������󣬼�������֮������Զ
% inf = 1000;
sdmatrix=adj_Matrix;
% �ڽӾ����е�0��ʾ����֮��û��ֱ�����ӣ���˶�����Ϊinf������adj(i,i)Ҫ��Ϊ0
sdmatrix(sdmatrix==0)=inf;
% �Խ�����Ϊ0
sdmatrix(logical(eye(size(sdmatrix))))=0;

nodeCount=size(sdmatrix,1);
for k=1:nodeCount
    for i=1:nodeCount
        for j=1:nodeCount
            
            %             if sdmatrix(i,j)>sdmatrix(i,k)+sdmatrix(k,j)...
            %                     && sdmatrix(i,k)<inf...
            %                     && sdmatrix(k,j)<inf
            
            if sdmatrix(i,j)>sdmatrix(i,k)+sdmatrix(k,j)
                sdmatrix(i,j)=sdmatrix(i,k)+sdmatrix(k,j);
            end
        end
    end
end


shortDistanceMatrix=sdmatrix;

end