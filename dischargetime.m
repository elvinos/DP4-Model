a = [0.5	0.7	1	2	3	4	5	7	];
b = [50	60	70	86	92	98	101	107	];

set(0,'defaultfigurecolor',[1 1 1]) % Set bacground colour to white
set(0,'DefaultAxesFontSize', 20)
set(0,'DefaultTextFontSize', 22)
Colcond = linspecer(3) ;
fit= polyfit(a,b/100,3);
x2 = linspace(min(a),max(a),numel(a));
ftot = polyval(fit,x2);
dp=plot(a,b,'Color',Colcond(2,:),'linewidth',2.5);
hold on
grid on
fp=plot(x2,ftot,'Color',Colcond(3,:),'linewidth',2.5);
title('Effect of Discharge Rate on Capacity','FontSize', 18)
xlabel('Discharge Time /hours','FontSize', 16)
ylabel('% of Rated Capacity','FontSize', 16)
xlim([min(a) max(a)]);
ylim([min(b) 110]);
% legend('Data', 'Fit')
legend(dp,'Data')
legend(fp,'Poly Fit')
