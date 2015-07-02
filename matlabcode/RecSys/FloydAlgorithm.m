function shortDistanceMatrix=FloydAlgorithm(adj_Matrix)
% floyd算法，计算一个邻接矩阵中各个点之间的最短距离
% 定义正无穷大，即两个点之间距离很远
% inf = 1000;
sdmatrix=adj_Matrix;
% 邻接矩阵中的0表示两点之间没有直接连接，因此都设置为inf，但是adj(i,i)要改为0
sdmatrix(sdmatrix==0)=inf;
% 对角线置为0
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