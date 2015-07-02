function [trustMatrixCommuMapCell,trustNodeMapCell]=GetTrustMatrixByCommunity(communityCell,socialMatrix)
% trustNodeMapCell ��ÿ���������û�ID��ӳ�䣬��ÿ�������ڲ���Ҫ���û����´�1��ʼ��ţ����㴦��
% ��1��Ϊӳ���������ڵ�ID����1��ʼ����2��Ϊ������ȫ�ֵ��û�ID���
% trustMatrixCommuMapCell��ÿ��������trust����

trustMatrixCommuMapCell=cell(length(communityCell),1);
trustNodeMapCell=cell(length(communityCell),1);
for i=1:length(communityCell)
    communityNodes=communityCell{i};
    nodeCount=length(communityNodes);
    % ����һ��
    communityNodes=sort(communityNodes);
    % ���ڼ���trust����ʱ��id�ִ�1��ʼ��ţ�������ǰ��nodeID��һ��ӳ��
    trustNodeMap=zeros(nodeCount,2);
    trustNodeMap(:,1)=(1:nodeCount);
    trustNodeMap(:,2)=communityNodes;
    trustNodeMapCell{i}=trustNodeMap;
    adj_Matrix=socialMatrix(communityNodes,communityNodes);
    % �����֮����̾���ľ���
    shortDistanceMatrix=FloydAlgorithm(adj_Matrix);
    % ��������֮���trustֵ
    maxShortDistance=max(max(shortDistanceMatrix));
    trustMatrix=(maxShortDistance-shortDistanceMatrix+1)/maxShortDistance;
    % �Խ�����Ϊ0
    trustMatrix(logical(eye(size(trustMatrix))))=0;
    trustMatrixCommuMapCell{i}=trustMatrix;
    
end



end