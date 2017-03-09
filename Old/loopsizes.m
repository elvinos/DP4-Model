%% Clear And Close
clc
clear all
close all force
% profile clear
% profile on
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

%% Battery Calculator



% Powerwall Calculation
% UFCost = 90000;
% INCost = 0;
% mainCost = 0;
s= 1;
minCAP=140;
maxCAP=300;
step=40;
h = waitbar(0,'Please wait...');
for newCap = minCAP:step:maxCAP
% newCap = 200; % kWH
ppkWh = 500;
ufcost(s) =ppkWh*newCap;
doD = 0.8;
curCap = ((1-doD)/2+doD)*newCap;
maxCap = ((1-doD)/2+doD)*newCap;
minCap=((1-doD)/2)*newCap;
% curCap = newCap;
batcap = curCap;
thermalDeg=0;
OOBDeg=0;
timetoCharge= 15/30;% kWh per halfHour
batteryEff =0.92;
curCap2=maxCap;
noCycles= 5000;
endlife= 0.8;
endlifeval=0.8*curCap2;
perCycleDeg=(curCap2-curCap2*endlife)/noCycles;
y= 1;
use= 0;
cycle = 0;
n=0;

loops= 50; % Guess Number of years to speed up Process
kwhcost = 500;
batteryuse = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
wkday = 0;
Rtot = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
Atot = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
Gtot = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
RtotwB = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
AtotwB = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
GtotwB = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
% batteryuse2 = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
DUoSCharge = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
DUoSChargewB = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
HHcharge = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
HHchargewB = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
% Daycharge=zeros(rowsDataMatmm30*loops,1);
Cap=zeros(rowsDataMatmm30*loops,colsDataMatmm30);
wkbatuse=zeros(rowsDataMatmm30*loops,colsDataMatmm30);
batcharge=zeros(rowsDataMatmm30*loops,colsDataMatmm30);
liveDataSelc= DataMatmm30;
liveDataSelc1=DataMatmm30;

tic
while curCap2 > endlifeval 
    n = n+1;
    if rem((n)/365,1) == 0
    liveDataSelc= vertcat(liveDataSelc,liveDataSelc1);
%     set( get(findobj(h,'type','axes'),'title'), 'string',num2str(n/365))
    end

    for c = 1:colsDataMatmm30
        if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0
            if 17*60 < TimeMM(1,c) && TimeMM(1,c) <= 19.5*60
              DUoSrate = rateA;
            else
              DUoSrate = rateG;
            end
        else
            wkday = wkday+1;
            if  TimeMM(1,c) <= 19*60 && TimeMM(1,c) > 17*60
                DUoSrate = rateR;
%                 wkbatuse(wkday,c)= liveDataSelc(n,c); %Cal for Weekday Usage Matrix for Histogram
            elseif 8*60 < TimeMM(1,c) && TimeMM(1,c) <= 17*60 || 19*60 < TimeMM(1,c) && TimeMM(1,c) <= 21.5*60
                DUoSrate = rateA;
%                 wkbatuse(wkday,c)= 0;
            else
                DUoSrate = rateG;
%                 wkbatuse(wkday,c)= 0;
            end
        end
            if DUoSrate == rateR
                if batcap < liveDataSelc(n,c) || batcap-minCap < liveDataSelc(n,c)
                    if minCap>0 && batcap-minCap < liveDataSelc(n,c)
                        batteryuse(n,c)= batcap-minCap;
                        batcap=minCap;
                    else
                    batteryuse(n,c)= -batcap;
                    end
                else
                batteryuse(n,c)= -liveDataSelc(n,c);
                end
                batcap=batcap+batteryuse(n,c);
                Rtot(n,c)= liveDataSelc(n,c);
                RtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
            elseif DUoSrate == rateA
%               batteryuse(n,c)=0;
              Atot(n,c)= liveDataSelc(n,c);
              AtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
            else
                if batcap < curCap2 && curCap2-batcap < timetoCharge
                    batteryuse(n,c)=curCap2-batcap;
                    batcap = curCap2;
                elseif batcap < curCap2
                    batteryuse(n,c)= timetoCharge;
                    batcap = batcap + batteryuse(n,c);
                else
%                     batteryuse(n,c) = 0;
                end
                Gtot(n,c)= liveDataSelc(n,c);
                GtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
            end

         if batteryuse(n,c) >= 0
               curCap2=curCap2-(batteryuse(n,c)*perCycleDeg/curCap2);
               Cap(n,c)=curCap2;
               use = batteryuse(n,c)+use;
               if curCap2 <= use
                   cycle=cycle + 1;
                   use = use-curCap2;
               end
         end
%       dataMatBat(n,c)=liveDataSelc(n,c)+batteryuse(n,c);
         batcharge(n,c)= batcap;
%         DUoSCharge(n,c)= (Gtot(n,c)+Atot(n,c)+Rtot(n,c))*DUoSrate;
%         DUoSChargewB(n,c)= (GtotwB(n,c)+AtotwB(n,c)+RtotwB(n,c))*DUoSrate; %Note Two Of these Values Should Always be 0
        HHcharge(n,c) = (liveDataSelc(n,c))*(DUoSrate+UnitRate); %Note Two Of these Values Should Always be 0
        HHchargewB(n,c) = (liveDataSelc(n,c)+batteryuse(n,c))*(DUoSrate+UnitRate); %Note Two Of these Values Should Always be 0

    end
%     c=1440;

     if rem((n)/365,1) == 0 || rem((n)/182,1) == 0 
%      waitbar((maxCap-Cap(n,c))/ (maxCap-endlifeval));
    end
    if n > 24*365
        break
    end
    
end

runtime=toc;
DaychargewB= (sum(HHchargewB')./100)'; %Daily Cost in Pounds
Daycharge= (sum(HHcharge')./100)'; %Daily Cost in Pounds


% if wkday > 0
%     wkdaybattotuse=sum(wkbatuse);
% end
% Display Savings
y = n/365;
for its=1:y
    itsstart=365*(its-1)+1;
    itsend=365*(its);
yearcharge(its) = sum(Daycharge(itsstart:itsend,:));
yearchargewB(its) = sum(DaychargewB(itsstart:itsend,:));
Savingpy(s,its) = yearcharge(its)-yearchargewB(its);
end

lifecharge = sum(Daycharge);
lifechargewB = sum(DaychargewB);
Saving(s) = lifecharge-lifechargewB;
disp(['Total Saved = £' num2str(Saving(s))]);

disp(['Years: ' num2str(n/365)]);
disp(['Cycles: ' num2str(cycle)]);
disp(['Run Time: ' num2str(runtime) ' Seconds']);

% batcharge(n:size(batcharge,1),:)=[];
% DUoS= sum(sum(DUoSCharge));
% DUoSwB= sum(sum(DUoSChargewB));
waitbar(((step*s))/ (maxCAP-minCAP));
s= s+1;
end
close(h)

totsaving= Saving-ufcost;

plot(minCAP:step:maxCAP,totsaving)
title('Battery Size vs Total Saving')
xlabel('Battery Size / kWh')
ylabel('Total Saving')
 

LineH = get(gca, 'children');
Value = get(LineH, 'YData');
Size = get(LineH, 'XData');


[maxValue, maxIndex] = max(Value);
maxSize = Size(maxIndex);

for bb = 1:(s-1)
    saving2 = Savingpy(bb,1);
    pbyear=1;
    while ufcost(bb) > saving2
        pbyear = pbyear+1;
        saving2 = sum(Savingpy(bb,1:pbyear));
    end
    ny(bb) = pbyear;
end
% batprice2=(50:10:1000);
% figure()
% plot(,batprice2);
% title('Payback Period for Battery Based on Cost pkWh')
% xlabel('Payback Time / Years')
% ylabel('Cost pkWh / £pkWh')
 
% totR= sum(sum(RtotwB));
% disp(totR);
% filename = 'batterycharge';
% xlswrite(filename,batcharge,'Sheet 1','A1')
% profile off
% 
% profile viewer