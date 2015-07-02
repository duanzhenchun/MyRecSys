function div_u =  computeDiv(mCell,itemset,item_prob)

div_u = 0; 
if isempty(mCell)
    div_u = 0;
else      
    hitList= mCell{3};
    if isempty(hitList)
        div_u = 0;
    else
        for k = 1:length(hitList) 
            item = hitList(k);
            idx = find(itemset == item );
            prob = item_prob(idx);
            div_u = div_u + prob * log(prob);
        end
        div_u = -div_u;
    end        
end



end