function dist=GetNeuroDistance(i,j,neuroCoordCell)
    iCoord=neuroCoordCell{i};
    jCoord=neuroCoordCell{j};
    % manhanttan dist 
    dist=sum(abs(iCoord-jCoord));
    
end
