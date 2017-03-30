a = [20	30	40	50	60	70	80];
b = [3300	2050	1475	1150	950	780	675];
c= [423.0769231	262.8205128	189.1025641	147.4358974	121.7948718	100	86.53846154];
figure()
set(0,'defaultfigurecolor',[1 1 1]) % Set bacground colour to white
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultTextFontSize', 22)
Colcond = linspecer(3) ;
fit= polyfit(a,c,4);
x2 = linspace(min(a),max(a),numel(a));
ftot = polyval(fit,x2);


fp=plot(x2,ftot,'Color',Colcond(3,:),'linewidth',2.5);
hold on
dp=scatter(a,c,'linewidth',2.5);
grid on
title('Effect of Depth of Discharge on Capacity','FontSize', 18)
xlabel('Depth of Discharge/ %','FontSize', 16)
ylabel('% of Rated Capacity','FontSize', 16)
xlim([min(a) max(a)]);
ylim([min(ftot),max(ftot)])
% ylim([min(b) 110]);
legend('Fit', 'Data')
% legend(dp,'Data')
% legend(fp,'Poly Fit')
