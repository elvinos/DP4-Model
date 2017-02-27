%% Clear And Close
clc
clear all
close all

%% Create Data

fileName = 'senateEDD.csv';

Data=senateEDD1(fileName);
rowsData= size(Data,1)-1;
colsData= size(Data,2);
DataMat = cell2mat(Data(2:rowsData,4:colsData));
rowsDataMat = size(DataMat,1);
colsDataMat = size(DataMat,2);

for c = 0.5:0.5:24
    cc= c*2;
    Time(:,cc)= c;
end
for n=1:rowsDataMat
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

for plsct=1:5
    figure(plsct)
    maxData1= max(DataMat(plsct,:)+1);
yyaxis left
ha = area([17 19], [maxData1 maxData1], 'FaceColor', [.7 .7 .7],'LineStyle','none');
hold on
ylabel('Energy Usage/ kWh')
plot(Time, DataMat(plsct,:))
hold on
plot(Time, Fit(plsct,:),'g')
xlim([0,24]);
ylim([10, maxData1]);
yyaxis right
plot(Time, DataMat(plsct,:)-Fit(plsct,:),'--');
ylabel('Battery Useage')
title({'Normal Usage Against Best Fit Battery: ',string(Data(plsct+1,1))})
xlabel('Time Of Day')
end
% Oldsize =  trapz(Time,DataMat(plsct,:));
% Newsize =  trapz(Time,Fit(plsct,:));
% Batterysize = Oldsize- Newsize;


%% Intergrate
sat = 0;
sun = 0;
for n=1:rowsDataMat
    if  rem((n+6)/7,1) == 0 % Finds Sundays
        disp(n)
        sun=sun+1;
    elseif rem((n)/7,1) == 0 % Finds Saturdays
        disp(n)
        sat=sat+1;
    else
    end
end
for n=2:6 % Week1
    sz(n-1)=trapz(Time,DataMat(n,:));
    meanwk1=mean(sz);
end
