function [quan_error,topo_error]=GetQualityMeasure(data,neuroMatrix,neuroCoordCell)
% 获取quantization error 和 topographic error
    dataNum=size(data,2);
    quan_error=0; % quantization error
    topo_error=0;
    for i=1:dataNum
        inputData=data(:,i);
        bestMatchID=GetBestMatch(inputData,neuroMatrix);
        bestMatchNeuro=neuroMatrix(:,bestMatchID);
        quan_error=quan_error+GetDistance(inputData,bestMatchNeuro);
        % 剔除第1个bestmatch neuro
        refinedNeuroMatrix=neuroMatrix;
        refinedNeuroMatrix(:,bestMatchID)=[];     
        secondBestMatchID=GetBestMatch(inputData,refinedNeuroMatrix);
        neuroDist=GetNeuroDistance(bestMatchID,secondBestMatchID,neuroCoordCell);
        if neuroDist~=1  % first BMU 和 second BMU 不邻接
            topo_error=topo_error+1;
        end             
    end
    quan_error=quan_error/dataNum;
    topo_error=topo_error/dataNum;
end