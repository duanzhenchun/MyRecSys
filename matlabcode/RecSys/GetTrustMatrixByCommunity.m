function [trustMatrixCommuMapCell,trustNodeMapCell]=GetTrustMatrixByCommunity(communityCell,socialMatrix)
% trustNodeMapCell 存每个社区内用户ID的映射，在每个社区内部，要将用户重新从1开始编号，方便处理
% 第1列为映射后的社区内的ID，从1开始，第2列为保留的全局的用户ID编号
% trustMatrixCommuMapCell存每个社区的trust矩阵

trustMatrixCommuMapCell=cell(length(communityCell),1);
trustNodeMapCell=cell(length(communityCell),1);
for i=1:length(communityCell)
    communityNodes=communityCell{i};
    nodeCount=length(communityNodes);
    % 排序一下
    communityNodes=sort(communityNodes);
    % 由于计算trust矩阵时，id又从1开始编号，所以提前把nodeID做一下映射
    trustNodeMap=zeros(nodeCount,2);
    trustNodeMap(:,1)=(1:nodeCount);
    trustNodeMap(:,2)=communityNodes;
    trustNodeMapCell{i}=trustNodeMap;
    adj_Matrix=socialMatrix(communityNodes,communityNodes);
    % 点与点之间最短距离的矩阵
    shortDistanceMatrix=FloydAlgorithm(adj_Matrix);
    % 计算点与点之间的trust值
    maxShortDistance=max(max(shortDistanceMatrix));
    trustMatrix=(maxShortDistance-shortDistanceMatrix+1)/maxShortDistance;
    % 对角线置为0
    trustMatrix(logical(eye(size(trustMatrix))))=0;
    trustMatrixCommuMapCell{i}=trustMatrix;
    
end



end