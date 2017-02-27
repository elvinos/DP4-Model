clc
clear all
close all
fileName = 'senateEDD.csv';

Data=senateEDD1(fileName);

% Time = cell2mat(Data(1,4:51));
% rowsData = size(Data,1) - 1;
% colsData = size(Data,2);
DataMat = cell2mat(Data(2:364,4:51));
rowsData = size(DataMat,1);
colsData = size(DataMat,2);

for c = 0.5:0.5:24
    cc= c*2;
    Time(:,cc)= c;
end
for n=1:rowsData
for m = 1:16
  if DataMat(n,m) > 10.5 
      Fit(n,m) = 10.5;
  else
      Fit(n,m) = DataMat(n,m);
  end
end

for m = 17:35
  if DataMat(n,m) > 16.5 
      Fit(n,m) = 16.5;
  else
      Fit(n,m) = DataMat(n,m);
  end
end

for m = 36:48
  if DataMat(n,m) > 13 
      Fit(n,m) = 13;
  else
      Fit(n,m) = DataMat(n,m);
  end
end
end

%% Do Some Plotting
plsct= 1; % Selects Data Set
yyaxis left
ha = area([17 18], [19 18], 'FaceColor', [.7 .7 .7],'LineStyle','none');
hold on
ylabel('Energy Usage/ kWh')
plot(Time, DataMat(plsct,:))
hold on
plot(Time, Fit(plsct,:),'g')
xlim([0,24])
ylim([10, 18])
yyaxis right
plot(Time, DataMat(plsct,:)-Fit(plsct,:),'--');
ylabel('Battery Useage')
title({'Normal Usage Against Best Fit Battery: ',string(Data(plsct+1,1))})
xlabel('Time Of Day')

Oldsize =  trapz(Time,DataMat(plsct,:));
Newsize =  trapz(Time,Fit(plsct,:));
Batterysize = Oldsize- Newsize;
