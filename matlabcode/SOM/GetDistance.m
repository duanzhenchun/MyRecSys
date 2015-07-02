function dist=GetDistance(vector1,vector2)
% 定义为欧式距离
dist=sqrt(sum((vector1-vector2).^2));
end