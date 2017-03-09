%% Clear And Close
clc
clear all
close all
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

loops= 40; % Guess Number of years to speed up Process
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


% Powerwall Calculation
UFCost = 90000;
INCost = 0;
mainCost = 0;
newCap = 200; % kWH
ppkWh = UFCost/newCap;
doD = 0.9;
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
year=1;

h = waitbar(0,'Please wait...');
tic
while curCap2 > endlifeval
    n = n+1;
    if rem((n)/365,1) == 0
    liveDataSelc= vertcat(liveDataSelc,liveDataSelc1);
    set( get(findobj(h,'type','axes'),'title'), 'string',num2str(n/365))
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

% battotuse(n,1)=sum(batteryuse(n,:));
if rem((n)/365,1) == 0 || rem((n)/182,1) == 0 
 waitbar((maxCap-Cap(n,c))/ (maxCap-endlifeval));
end

if rem((n)/365,1) == 0
    yearchargewB(year,:) = sum(sum(HHchargewB(n-364:n,1:1440))');
    yearcharge(year,:) = sum(sum(HHcharge(n-364:n,1:1440))');
    batcap2(year)= Cap(n,1440);
    RtotwB2(year)= sum(sum(RtotwB(n-364:n,1:1440)));
    Rtot2(year)= sum(sum(Rtot(n-364:n,1:1440)));
    year = year + 1;
end

end

yeartot=sum(yearcharge-yearchargewB)';

runtime=toc;
DaychargewB= (sum(HHchargewB')./100)'; %Daily Cost in Pounds
Daycharge= (sum(HHcharge')./100)'; %Daily Cost in Pounds
savday=Daycharge-DaychargewB;

nds=1;
sav3=savday(1);
while UFCost > sav3
    nds=nds+1;
    sav3= sum(savday(1:nds,1));
end

% if wkday > 0
%     wkdaybattotuse=sum(wkbatuse);
% end
% Display Savings

y = n/365;
s=1;
for its=1:y
    itsstart=365*(its-1)+1;
    itsend=365*(its);
Savingpy(s,its) = sum(savday(itsstart:itsend,:))';
end
s=2;
for bb = 1:(s-1)
    saving2 = Savingpy(bb,1);
    pbyear=1;
    while UFCost(bb) > saving2
        pbyear = pbyear+1;
        saving2 = sum(Savingpy(bb,1:pbyear));
    end
    ny(bb) = pbyear;
end


lifecharge = sum(Daycharge);
lifechargewB = sum(DaychargewB);
Saving = lifecharge-lifechargewB;
disp(['Total Saved = £' num2str(Saving)]);
close(h)
disp(['Years: ' num2str(n/365)]);
disp(['Cycles: ' num2str(cycle)]);
disp(['Run Time: ' num2str(runtime) ' Seconds']);
batcharge(n:size(batcharge,1),:)=[];
DUoS= sum(sum(DUoSCharge));
DUoSwB= sum(sum(DUoSChargewB));
% totR= sum(sum(RtotwB));
% disp(totR);
% filename = 'batterycharge';
% xlswrite(filename,batcharge,'Sheet 1','A1')
% profile off
% 
% profile viewer