
data = [1 2 ; 3 4 ; 5 6 ; 7 8 ; 9 10 ;11 12];
haha = zeros(6,1);
idxSetCell= cell(3,1);
idxSetCell{1} = [1 ,2];
idxSetCell{2} = [3 ,4];
idxSetCell{3} = [5 ,6];
spmd(0)
    idx = idxSetCell{labindex};
    haha(idx) = data(idx) *2;
end
