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



%% Battery Calculator
kwhcost = 500;
batteryuse = zeros(rowsDataMat,colsDataMat);
wkday = 0;

% Powerwall Calculation
UFCost = 90000;
INCost = 0;
mainCost = 0;
newCap = 200; % kWH
curCap = newCap;
batcap = curCap;
ppkWh = UFCost/newCap;
perCycleDeg = 0.0336;
thermalDeg=0;
OOBDeg=0;
timetoCharge= 15;% kWh per halfHour
batteryEff =0.92;
dataMatBat=DataMat;

for n=1:rowsDataMat
    if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0
    else
        wkday = wkday+1;
    end
    for c = 1:48
        
        if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0
            day = 'wkend';
            if 17 <= Time(1,c) && Time(1,c) <= 19.5
                 batteryuse(n,c)=0;
                 batcap=batcap;
            else
                 batteryuse(n,c)=0;               
                 %Battery Capacity Charge
                 if batcap < curCap && curCap-batcap < timetoCharge 
                    dataMatBat(n,c)=dataMatBat(n,c)+ curCap-batcap;
                    batcap = curCap;
                   
                elseif batcap < curCap
                    dataMatBat(n,c)=dataMatBat(n,c)+ timetoCharge;
                    batcap = batcap + timetoCharge;
                end
                 
            end
        else
            day = 'wkday';
            if  Time(1,c) <= 19 && Time(1,c) > 17
                batteryuse(n,c)= DataMat(n,c);
                batcap=batcap-DataMat(n,c); % Capacity of battery
                wkbatuse(wkday,c)= DataMat(n,c); %Cal for Weekday Usage Matrix for Histogram 
            elseif 8 <= Time(1,c) && Time(1,c) <= 17 || 19 < Time(1,c) && Time(1,c) <= 21.5
                batteryuse(n,c)=0;
                wkbatuse(wkday,c)= 0;
            else
                if batcap < curCap && curCap-batcap < timetoCharge 
                    dataMatBat(n,c)=dataMatBat(n,c)+ curCap-batcap;
                    batcap = curCap;         
                elseif batcap < curCap 
                    dataMatBat(n,c)=dataMatBat(n,c)+ timetoCharge;
                    batcap = batcap + timetoCharge;
                end
                batteryuse(n,c)=0;
                wkbatuse(wkday,c)= 0;
            end
        
        end
    batcharge(n,c)= batcap;
    end
    
    if wkday > 0
    wkdaybattotuse(wkday,1)=sum(wkbatuse(wkday,:));
    end
    battotuse(n,1)=sum(batteryuse(n,:));
end

saving= sum(battotuse*(rateR-rateG))/100;
sumbatuse = sum(sum(battotuse));
maxcapacity = max(battotuse);
meanuseage = mean(battotuse);
batcapacity = maxcapacity*1.1; %kWh
batcost = kwhcost*batcapacity;
nyears = batcost/saving;

batprice2=(50:10:1000);
batcost2=batprice2.*batcapacity;
nyears2=batcost2./saving;
plot(nyears2,batprice2);
title('Payback Period for Battery Based on Cost pkWh')
xlabel('Payback Time / Years')
ylabel('Cost pkWh / £pkWh')

% Plot Trend From Battery Usage Data
histfit(wkdaybattotuse)

% for n=1:rowsDataMat
%     for c = 1:48
%             if  Time(1,c) <= 19 && Time(1,c) > 17
%                 batteryuse(n,c)= DataMat(n,c);
%             elseif 8 <= Time(1,c) && Time(1,c) <= 17 || 19 < Time(1,c) && Time(1,c) <= 21.5
%                 batteryuse(n,c)=0;
%             else
%                 batteryuse(n,c)=0;
%             end
% 
%     end        
% end
    
for plsct=2:2
    figure(plsct)
    maxData1= max(DataMat(plsct,:)+1);
    ha = area([17.5 19.5], [maxData1 maxData1], 'FaceColor', [.7 .7 .7],'LineStyle','none');
    hold on
    ylabel('Energy Usage/ kWh')
    plot(Time, DataMat(plsct,:))
    hold on
    plot(Time, batteryuse(plsct,:),'g')
    xlim([0,24]);
    ylim([10, maxData1]);
    plot(Time, DataMat(plsct,:)-batteryuse(plsct,:),'--');
    ylabel('Battery Useage')
    title({'Normal Usage Against Best Fit Battery: ',string(Data(plsct+1,1))})
    xlabel('Time Of Day')
    figure(3)
    ha = area([17.5 19.5], [maxData1 maxData1], 'FaceColor', [.7 .7 .7],'LineStyle','none');
hold on
    yyaxis left
    plot(Time, DataMat(plsct,:))
    hold on
    plot(Time, dataMatBat(plsct,:))
    yyaxis right
    plot(Time, batcharge(plsct,:))
    
end