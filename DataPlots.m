%% Clear And Close
clc
clear all
close all

%% Variables
plsct = 1; %Select the number of Plots to Create

% Rates in Pence
UnitRate = 6.832;
rateR=24.41;
rateA=0.287;
rateG=0.161;

%% Create Data

fileName = 'senateEDD.csv';

Data=senateEDD1(fileName);
rowsData= size(Data,1);
colsData= size(Data,2);
DataMat = cell2mat(Data(2:rowsData,4:colsData));
rowsDataMat = size(DataMat,1);
colsDataMat = size(DataMat,2);
for c = 0.5:0.5:24
    cc= c*2;
    Time(:,cc)= c;
end

%% Fit Plot

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

%% Costs
Rtot = zeros(rowsDataMat,colsDataMat);
Atot = zeros(rowsDataMat,colsDataMat);
Gtot = zeros(rowsDataMat,colsDataMat);
DUoSCharge = zeros(rowsDataMat,colsDataMat);
HHcharge = zeros(rowsDataMat,colsDataMat);
Daycharge=zeros(rowsDataMat,1);


% Calculate Unit Charge
for n=1:rowsDataMat

    for c = 1:48
        
    if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0 % Finds Sundays
        if 17 <= Time(1,c) && Time(1,c) <= 19.5
            DUoSrate = rateA;
            Atot(n,c)= DataMat(n,c)*rateA;
        else
            DUoSrate = rateG;
            Gtot(n,c)= DataMat(n,c)*rateG;
        end
    else
        if  Time(1,c) <= 19 && Time(1,c) > 17
            DUoSrate = rateR;
            Rtot(n,c)= DataMat(n,c)*rateR;
        elseif 8 <= Time(1,c) && Time(1,c) <= 17 || 19 < Time(1,c) && Time(1,c) <= 21.5
            DUoSrate = rateA;
            Atot(n,c)= DataMat(n,c)*rateA;
        else
            DUoSrate = rateG;
            Gtot(n,c)= DataMat(n,c)*rateG;
        end
        
    end
    DUoSCharge(n,c)= DataMat(n,c)*DUoSrate;
    HHcharge(n,c) = DataMat(n,c)*(DUoSrate+UnitRate);
    end
    Daycharge(n,:)= sum(HHcharge(n,:))./100; %Daily Cost in Pounds
end

chargeR=sum(sum(Rtot))/100;
chargeA=sum(sum(Atot))/100;
chargeG=sum(sum(Gtot))/100;
DUoSTot= sum(sum(DUoSCharge))/100;
TotUnit= sum(sum(DataMat));
Yearcharge = sum(Daycharge);


%% Do Some Plotting
for plsct=2:2
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


%% Mean Power Useage
sat = 0;
sun = 0;
count = 0;
week = 1;
daycount = 1;
weekarray(week,:)= week;
sz=zeros(52,5);
% dailyuse= zeros(365,1);
for n=1:rowsDataMat
    if  rem((n+6)/7,1) == 0 % Finds Sundays
        sun=sun+1;
    elseif rem((n)/7,1) == 0 % Finds Saturdays
        sat=sat+1;
    else
        count = count+ 1;
        if  count < 6
            sz(week,count)=sum(DataMat(n,:));
            weekData(daycount,:)= DataMat(n,:);
            dailyuse(daycount,1)=sz(week,count);
            dc(daycount,1)=daycount;
            daycount= daycount+1;
            if count == 5
            sz(week,6)= mean(sz(week,:));
            end
        else
            week = week + 1;
            weekarray(week,:)= week;
            count = 1;
            sz(week,count)=sum(DataMat(n,:));
            weekData(daycount,:)= DataMat(n,:);
            dailyuse(daycount,1)=sz(week,count);
            dc(daycount,1)=daycount;
            daycount= daycount+1;
        end
    end
end
%Create Graph to Show Mean Weekly (Weekday) Usage For the Year
figure(plsct+1);
plot(weekarray, sz(1:52,6))
title('Mean Weekly Power Usage Across Senate House')
xlabel('Week')
ylabel('Mean Weekly Power Useage /KwH')
xlim([1,52])

% Create Graph Showing Mean Weekday Power Usage Across the Year (Not
% including Weekends
dc365= dc.*7./5; % Take Daily Usage and Multiply to Give Representation for the Year
figure(plsct+2); 
plot(dc365, dailyuse)
title('Mean Daily Power Usage Across Senate House')
xlabel('Day')
ylabel('Mean Daily Power Useage /KwH')
xlim([1,365])

%% Battery Calculator

batcapacity = 555; %kWh
batcost = 500000;
batteryuse = zeros(rowsDataMat,colsDataMat);
for n=1:rowsDataMat
for c = 1:48
    if 17 <= Time(1,c) && Time(1,c) <= 19.5
        batteryuse(n,c)=DataMat(n,c);
        batcapacity(n,1)=sum(batteryuse(n,c));
    else
        batteryuse(n,c)=0;
    end
end
end


