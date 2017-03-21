figure()
x=sizeR2(1:range);
y=sorttotsaving(1:range);
scatter(x,y);
title('Battery Size vs Total Saving (Cond.)')
xlabel('Battery Size / kWh')
ylabel('Total Saving/ £')
hold on
[xfit,pfit] = maxFitfunc(x,y);
plot(xfit,pfit)