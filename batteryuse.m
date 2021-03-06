function [batteryuse]=batteryuse()

% Variables
plsct = 1; %Select the number of Plots to Create

% Rates in Pence
UnitRate = 6.832;
rateR=24.41;
rateA=0.287;
rateG=0.161;

% Create Data
fileName = 'senateEDD.csv';
Data=senateEDD1(fileName);
rowsData= size(Data,1);
colsData= size(Data,2);
DataMat = cell2mat(Data(2:rowsData,4:colsData));
rnfit=2;
[livedata,DataMatmm30] =liveDatafunc(rnfit);
rowsDataMatmm30 = size(DataMatmm30,1);
colsDataMatmm30 = size(DataMatmm30,2);
for c = 0.5:0.5:24
    cc= c*2;
    TimeHH(:,cc)= c;
    for m=1:30
     mm = (cc-1)*30 + m;
     TimeMM(:,mm)= mm;
    end
end

% Battery Calculator
kwhcost = 500;
batteryuse = zeros(rowsDataMatmm30,colsDataMatmm30);
wkday = 0;
% Rtot = zeros(rowsDataMatmm30,colsDataMatmm30);
% Atot = zeros(rowsDataMatmm30,colsDataMatmm30);
% Gtot = zeros(rowsDataMatmm30,colsDataMatmm30);
% RtotwB = zeros(rowsDataMatmm30,colsDataMatmm30);
% AtotwB = zeros(rowsDataMatmm30,colsDataMatmm30);
% GtotwB = zeros(rowsDataMatmm30,colsDataMatmm30);
% DUoSCharge = zeros(rowsDataMatmm30,colsDataMatmm30);
% HHcharge = zeros(rowsDataMatmm30,colsDataMatmm30);
% Daycharge=zeros(rowsDataMatmm30,1);

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
timetoCharge= 15/30;% kWh per halfHour
batteryEff =0.92;
liveDataSelc=DataMatmm30;
dataMatBat=DataMatmm30;

for n=1:rowsDataMatmm30
%     if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0 % Uses Sunday as The First Day
%     else
%         wkday = wkday+1;
%     end

    for c = 1:1440
        if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0
%             day = 'wkend';
            if 17*60 < TimeMM(1,c) && TimeMM(1,c) <= 19.5*60
                 batteryuse(n,c)=0;
                 batcap=batcap;
%                  DUoSrate = rateA;
%                  rate(n,c)=2;
%                  Atot(n,c)= liveDataSelc(n,c);
%                  AtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
            else
                 %Battery Capacity Charge
                if batcap < curCap && curCap-batcap < timetoCharge
                    batteryuse(n,c)=curCap-batcap;
                    batcap = curCap;
                elseif batcap < curCap
                    batteryuse(n,c)= timetoCharge;
                    batcap = batcap + batteryuse(n,c);
                else
                    batteryuse(n,c) = 0;
                end
%               DUoSrate = rateG;
%               rate(n,c)=1;
%               Gtot(n,c)= liveDataSelc(n,c);
%               GtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
            end
        else
            day = 'wkday';
            if  TimeMM(1,c) <= 19*60 && TimeMM(1,c) > 17*60
                batteryuse(n,c)= -liveDataSelc(n,c);
                batcap=batcap+batteryuse(n,c); % Capacity of battery
%                 wkbatuse(wkday,c)= -batteryuse(n,c); %Cal for Weekday Usage Matrix for Histogram
%                 DUoSrate = rateR;
%                 rate(n,c)=3;
%                 Rtot(n,c)= liveDataSelc(n,c);
%                 RtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
            elseif 8*60 < TimeMM(1,c) && TimeMM(1,c) <= 17*60 || 19*60 < TimeMM(1,c) && TimeMM(1,c) <= 21.5*60
                batteryuse(n,c)=0;
%                 wkbatuse(wkday,c)= 0;
%                 DUoSrate = rateA;
%                 Atot(n,c)= liveDataSelc(n,c);
%                 AtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
%                 rate(n,c)=2;
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
%                 DUoSrate = rateG;
%                 Gtot(n,c)= liveDataSelc(n,c);
%                 GtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
%                 rate(n,c)=1;
%                 wkbatuse(wkday,c)= 0;
            end

        end
%     dataMatBat(n,c)=DataMatmm30(n,c)+batteryuse(n,c);
%     batcharge(n,c)= batcap;
%     DUoSCharge(n,c)= (GtotwB(n,c)+AtotwB(n,c)+RtotwB(n,c))*DUoSrate; %Note Two Of these Values Should Always be 0
%     HHcharge(n,c) = (Gtot(n,c)+Atot(n,c)+Rtot(n,c))*(DUoSrate+UnitRate); %Note Two Of these Values Should Always be 0
%     HHchargewB(n,c) = (GtotwB(n,c)+AtotwB(n,c)+RtotwB(n,c))*(DUoSrate+UnitRate); %Note Two Of these Values Should Always be 0
    end

%     DaychargewB(n,:)= sum(HHchargewB(n,:))./100; %Daily Cost in Pounds
%     Daycharge(n,:)= sum(HHcharge(n,:))./100; %Daily Cost in Pounds
%     if wkday > 0
%     wkdaybattotuse(wkday,1)=sum(wkbatuse(wkday,:));
%     end
%     battotuse(n,1)=sum(batteryuse(n,:));
end


end