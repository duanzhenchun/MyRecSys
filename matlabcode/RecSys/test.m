ratingSomFileName='..\..\..\data\baidu\data1\baidu_10x10_som1.mat';

load(ratingSomFileName, 'uniqUserData', 'uniqItemData', ...
    'userRatingMatrix','weight', 'itemClassIndex');