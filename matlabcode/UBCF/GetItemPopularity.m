function itemSet = GetItemPopularity(userRatingMatrix)
    itemCount = size (userRatingMatrix,2);
    itemSet = zeros(itemCount, 2);
    itemSet(:,1) = 1:itemCount;
    
    itemRatingNum = sum(userRatingMatrix>0,1);
    itemSet(:,2)  = itemRatingNum;

end