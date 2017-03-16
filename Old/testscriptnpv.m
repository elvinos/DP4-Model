x= sizeRange;
y=npv1;



p = polyfit(x,y,3)
x2 = linspace(100,6930,103);
f2 = polyval(p,x2);
plot(x,y,'*',x2,f2,'-')
f = polyval(p,x);
T = table(x,y,f,y-f,'VariableNames',{'X','Y','Fit','FitError'})

x2 = linspace(100,6930,103);


figure()

