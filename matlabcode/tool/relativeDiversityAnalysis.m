
function avgdiv = relativeDiversityAnalysis(m1Info, m2Info)

realUserCount = 0;
div = 0;
testUserCount = length(m1Info);

for i= 1:testUserCount
    m1Cell = m1Info{i};
    if isempty(m1Cell)
        continue
    end
    m1HitList = m1Cell{3};
    m2Cell = m2Info{i};
    if isempty(m2Cell)
        continue
    end
    m2HitList = m2Cell{3};
    
    commonHitList =  intersect(m1HitList,m2HitList);
    
    if isempty(commonHitList)
        continue;
    else
        commonLen = length(commonHitList);
        prob_m1 = 1/length(m1HitList);
        prob_m2 = 1/length(m2HitList);
        div_u = 0;
        for j = 1:commonLen
            tempdiv = prob_m1 * log(prob_m1/prob_m2);
            div_u = div_u + tempdiv;
        end
        div = div + div_u;
        realUserCount = realUserCount + 1;
    end
    
end
avgdiv = div/realUserCount;

end