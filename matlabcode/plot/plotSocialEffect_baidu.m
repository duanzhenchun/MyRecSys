
socialEffectFileName = sprintf('..\\..\\..\\data\\baidu\\finaldata\\socialEffect.txt');
effect = load(socialEffectFileName);

x = [1,2,3,4,5,6];
y1 = effect(:,1);
y2 = effect(:,3);

subplot(211);
p = plot(x,y1,'b-',x,y2,'r-');


x = (1:6);
y1 = effect(:,2);
y2 = effect(:,4);
subplot(212);
p = plot(x,y1,'b-',x,y2,'r-');