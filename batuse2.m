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
RtotwB = zeros(rowsDataMat,colsDataMat);
AtotwB = zeros(rowsDataMat,colsDataMat);
GtotwB = zeros(rowsDataMat,colsDataMat);
DUoSCharge = zeros(rowsDataMat,colsDataMat);
HHcharge = zeros(rowsDataMat,colsDataMat);
Daycharge=zeros(rowsDataMat,1);

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
            if 17 < Time(1,c) && Time(1,c) <= 19.5
                 batteryuse(n,c)=0;
                 batcap=batcap;
                 DUoSrate = rateA;
                 Atot(n,c)= DataMat(n,c);
                 AtotwB(n,c)= (DataMat(n,c)+batteryuse(n,c));
            else
                 if batcap < curCap && curCap-batcap < timetoCharge
                    batteryuse(n,c) = + curCap-batcap;
                    dataMatBat(n,c)=DataMat(n,c)+ batteryuse(n,c);
                    batcap = curCap;
                elseif batcap < curCap
                    batteryuse(n,c)= timetoCharge;
                    dataMatBat(n,c)=DataMat(n,c)+ batteryuse(n,c);
                    batcap = batcap + batteryuse(n,c);
                else
                    batteryuse(n,c)=0;
                end
              DUoSrate = rateG;
              Gtot(n,c)= DataMat(n,c);
              GtotwB(n,c)= (DataMat(n,c)+batteryuse(n,c));
            end
        else
            day = 'wkday';
            if  Time(1,c) <= 19 && Time(1,c) > 17
                batteryuse(n,c)= -DataMat(n,c);
                batcap=batcap+batteryuse(n,c); % Capacity of battery
                wkbatuse(wkday,c)= DataMat(n,c); %Cal for Weekday Usage Matrix for Histogram
                DUoSrate = rateR;
                Rtot(n,c)= DataMat(n,c);
                RtotwB(n,c)= (DataMat(n,c)+batteryuse(n,c));
            elseif 8 < Time(1,c) && Time(1,c) <= 17 || 19 < Time(1,c) && Time(1,c) <= 21.5
                batteryuse(n,c)=0;
                wkbatuse(wkday,c)= 0;
                DUoSrate = rateA;
                Atot(n,c)= DataMat(n,c);
                AtotwB(n,c)= (DataMat(n,c)+batteryuse(n,c));
                rate(n,c)=2;
            else
                if batcap < curCap && curCap-batcap < timetoCharge
                    batteryuse(n,c)=curCap-batcap;
                    batcap = curCap;
                elseif batcap < curCap
                    batteryuse(n,c)=timetoCharge;
                    batcap = batcap + batteryuse(n,c);
                else
                    batteryuse(n,c)=0;
                end
                DUoSrate = rateG;
                Gtot(n,c)= DataMat(n,c);
                GtotwB(n,c)= (DataMat(n,c)+batteryuse(n,c));
                rate(n,c)=1;
                wkbatuse(wkday,c)= 0;
            end
        end
    dataMatBat(n,c)=DataMat(n,c)+batteryuse(n,c);
    batcharge(n,c)= batcap;
    DUoSCharge(n,c)= (GtotwB(n,c)+AtotwB(n,c)+RtotwB(n,c))*DUoSrate; %Note Two Of these Values Should Always be 0
    HHcharge(n,c) = (Gtot(n,c)+Atot(n,c)+Rtot(n,c))*(DUoSrate+UnitRate); %Note Two Of these Values Should Always be 0
    HHchargewB(n,c) = (GtotwB(n,c)+AtotwB(n,c)+RtotwB(n,c))*(DUoSrate+UnitRate); %Note Two Of these Values Should Always be 0
    end
    DaychargewB(n,:)= sum(HHchargewB(n,:))./100; %Daily Cost in Pounds
    Daycharge(n,:)= sum(HHcharge(n,:))./100; %Daily Cost in Pounds
    if wkday > 0
    wkdaybattotuse(wkday,1)=sum(wkbatuse(wkday,:));
    end
    battotuse(n,1)=sum(batteryuse(n,:));
end


figure(4)
plot(Time(1,:),RtotwB(2,:),'r');
hold on
plot(Time(1,:),AtotwB(2,:),'y');
plot(Time(1,:),GtotwB(2,:),'g');
plot(Time(1,:),Rtot(2,:),'r--');
plot(Time(1,:),Atot(2,:),'y--');
plot(Time(1,:),Gtot(2,:),'g--');
chargeR=sum(sum(Rtot));
chargeA=sum(sum(Atot));
chargeG=sum(sum(Gtot));
totunitDUoS=chargeR+chargeA+chargeG
chargeRb=sum(sum(RtotwB));
chargeAb=sum(sum(AtotwB));
chargeGb=sum(sum(GtotwB));
totunitDUoSb=chargeRb+chargeAb+chargeGb
DUoSTot= sum(sum(DUoSCharge))/100;
TotUnit= sum(sum(DataMat));
sumbatuse = sum(sum(battotuse));

% Display Savings
Yearcharge = sum(Daycharge)
YearchargewB = sum(DaychargewB)
Saving = Yearcharge-YearchargewB

% maxcapacity = max(battotuse);
% meanuseage = mean(battotuse);
% batcapacity = maxcapacity*1.1; %kWh
% batcost = kwhcost*batcapacity;
% nyears = batcost/saving;

% batprice2=(50:10:1000);
% batcost2=batprice2.*batcapacity;
% nyears2=batcost2./saving;
% plot(nyears2,batprice2);
% title('Payback Period for Battery Based on Cost pkWh')
% xlabel('Payback Time / Years')
% ylabel('Cost pkWh / ?pkWh')

% Plot Trend From Battery Usage Data
% histfit(wkdaybattotuse)

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

% for plsct=2:2
%     figure(plsct)
%     maxData1= max(DataMat(plsct,:)+1);
%     ha = area([17.5 19.5], [maxData1 maxData1], 'FaceColor', [.7 .7 .7],'LineStyle','none');
%     hold on
%     ylabel('Energy Usage/ kWh')
%     plot(Time, DataMat(plsct,:))
%     hold on
%     plot(Time, batteryuse(plsct,:),'g')
%     xlim([0,24]);
%     ylim([10, maxData1]);
%     plot(Time, DataMat(plsct,:)-batteryuse(plsct,:),'--');
%     ylabel('Battery Useage')
%     title({'Normal Usage Against Best Fit Battery: ',string(Data(plsct+1,1))})
%     xlabel('Time Of Day')
%     figure(3)
%     ha = area([17.5 19.5], [maxData1 maxData1], 'FaceColor', [.7 .7 .7],'LineStyle','none');
% hold on
%     yyaxis left
%     plot(Time, DataMat(plsct,:))
%     hold on
%     plot(Time, dataMatBat(plsct,:))
%     yyaxis right
%     plot(Time, batcharge(plsct,:))
%
% end
