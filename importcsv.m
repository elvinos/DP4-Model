%% Clear
clc
clear all
close all



%% Plot
fileName = 'testdata2.csv';
[Time Energy Fit] = csvimport( fileName, 'columns', {'a', 'b','c'} );

Time = Time/60;
% plot(Time, Fit);

for m = 1:16
  if Energy(m) > 10.5 
      fit2(m,:) = 10.5;
  else
      fit2(m,:) = Energy(m);
  end
end

for m = 17:35
  if Energy(m) > 16.5 
      fit2(m,:) = 16.5;
  else
      fit2(m,:) = Energy(m);
  end
end

for m = 36:47
  if Energy(m) > 13 
      fit2(m,:) = 13;
  else
      fit2(m,:) = Energy(m);
  end
end

batuse=[Energy fit2 (Fit-fit2)]

yyaxis left
ha = area([17 18], [19 18], 'FaceColor', [.7 .7 .7],'LineStyle','none');
hold on
ylabel('Energy Usage/ kWh')
plot(Time, Energy);
plot(Time, fit2,'g');
xlim([0,24])
ylim([10, 18])
yyaxis right
plot(Time, Energy-fit2,'--');
ylabel('Battery Useage')
title('Normal Usage Against Best Fit Battery ')
xlabel('Time Of Day')
set(gca,'Ydir','reverse')


Oldsize =  trapz(Time,Energy)
Newsize =  trapz(Time,fit2)

Batterysize = Oldsize- Newsize



