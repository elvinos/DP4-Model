%% Clear And Close
clc
clear all
close all

profile on
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
loops= 27;
kwhcost = 500;
batteryuse = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
wkday = 0;
Rtot = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
Atot = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
Gtot = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
RtotwB = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
AtotwB = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
GtotwB = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
batteryuse2 = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
DUoSCharge = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
HHcharge = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
Daycharge=zeros(rowsDataMatmm30*loops,1);

% Powerwall Calculation
UFCost = 90000;
INCost = 0;
mainCost = 0;
newCap = 200; % kWH
curCap = [newCap];
batcap = [curCap];
ppkWh = UFCost/newCap;
% perCycleDeg = 0.0336;
thermalDeg=0;
OOBDeg=0;
timetoCharge= [15/30];% kWh per halfHour
batteryEff =0.92;
% liveDataSelc=zeros(rowsDataMatmm30*loops,colsDataMatmm30);
liveDataSelc= DataMatmm30;
% liveDataSelc(1:rowsDataMatmm30,1:colsDataMatmm30) = DataMatmm30;
liveDataSelc1=DataMatmm30;
dataMatBat=DataMatmm30;

%% Battery Deg
curCap2=200;
noCycles= 5000;
endlife= 0.8;
perCycleDeg=(curCap2-curCap2*endlife)/noCycles;
y= 1;
use= 0;
cycle = 0;
n=0;

h = waitbar(0,'Please wait...');
tic;
while curCap2(1) > 160
    n = n+1;
    if rem((n)/365,1) == 0
    liveDataSelc= vertcat(liveDataSelc,liveDataSelc1);
    Rtot = vertcat(Rtot,zeros(rowsDataMatmm30,colsDataMatmm30));
    Atot = vertcat(Atot,zeros(rowsDataMatmm30,colsDataMatmm30));
    Gtot = vertcat(Gtot,zeros(rowsDataMatmm30,colsDataMatmm30));
    RtotwB = vertcat(RtotwB,zeros(rowsDataMatmm30,colsDataMatmm30));
    AtotwB = vertcat(AtotwB,zeros(rowsDataMatmm30,colsDataMatmm30));
    GtotwB = vertcat(GtotwB,zeros(rowsDataMatmm30,colsDataMatmm30));
    batteryuse2 = vertcat(batteryuse2,zeros(rowsDataMatmm30,colsDataMatmm30));
    DUoSCharge = vertcat(DUoSCharge,GtotwB,zeros(rowsDataMatmm30,colsDataMatmm30));
    HHcharge = vertcat(HHcharge,zeros(rowsDataMatmm30,colsDataMatmm30));
    Daycharge=vertcat(Daycharge,zeros(rowsDataMatmm30,1));
    set( get(findobj(h,'type','axes'),'title'), 'string',num2str(n/365))
    end

    if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0 % Uses Sunday as The First Day
    else
        wkday = wkday+1;
    end

    for c = 1:1440
       if c >1  
        batcap(c)= batcap(c-1);
        curCap2(c)= curCap2(c-1);
        use(c)= use(c-1);
       end
        if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0
            day = 'wkend';
            if 17*60 < TimeMM(1,c) && TimeMM(1,c) <= 19.5*60
                 batteryuse(n,c)=0;
                 batcap(c)=batcap(c);
                 DUoSrate = rateA;
                 rate(n,c)=2;
                 Atot(n,c)= liveDataSelc(n,c);
                 AtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
            else
                 %Battery Capacity Charge
                if batcap(c) < curCap(1) && curCap(1)-batcap(c) < timetoCharge(1)
                    batteryuse(n,c)=curCap(1)-batcap(c);
                    batcap(c) = curCap(1);
                elseif batcap(c) < curCap(1)
                    batteryuse(n,c)= timetoCharge(1);
                    batcap(c) = batcap(c) + batteryuse(n,c);
                else
                    batteryuse(n,c) = 0;
                end
              DUoSrate = rateG;
              rate(n,c)=1;
              Gtot(n,c)= liveDataSelc(n,c);
              GtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
            end
        else
            day = 'wkday';
            if  TimeMM(1,c) <= 19*60 && TimeMM(1,c) > 17*60
                batteryuse(n,c)= -liveDataSelc(n,c);
                batcap(c)=batcap(c)+batteryuse(n,c); % Capacity of battery
                wkbatuse(wkday,c)= -batteryuse(n,c); %Cal for Weekday Usage Matrix for Histogram
                DUoSrate = rateR;
                rate(n,c)=3;
                Rtot(n,c)= liveDataSelc(n,c);
                RtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
            elseif 8*60 < TimeMM(1,c) && TimeMM(1,c) <= 17*60 || 19*60 < TimeMM(1,c) && TimeMM(1,c) <= 21.5*60
                batteryuse(n,c)=0;
                wkbatuse(wkday,c)= 0;
                DUoSrate = rateA;
                Atot(n,c)= liveDataSelc(n,c);
                AtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
                rate(n,c)=2;
            else
                if batcap(c) < curCap(1) && curCap(1)-batcap(c) < timetoCharge(1)
                    batteryuse(n,c)=curCap(1)-batcap(c);
                    batcap(c) = curCap(1);
                elseif batcap(c) < curCap(1)
                    batteryuse(n,c)=timetoCharge(1);
                    batcap(c) = batcap(c) + batteryuse(n,c);
                else
                    batteryuse(n,c)=0;
                end
                DUoSrate = rateG;
                Gtot(n,c)= liveDataSelc(n,c);
                GtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
                rate(n,c)=1;
                wkbatuse(wkday,c)= 0;
            end
        
        end
        
%         dataMatBat(n,c)=liveDataSelc(n,c)+batteryuse(n,c);
        batcharge(n,c)= batcap(c);
%         DUoSCharge(n,c)= (GtotwB(n,c)+AtotwB(n,c)+RtotwB(n,c))*DUoSrate; %Note Two Of these Values Should Always be 0
        HHcharge(n,c) = (Gtot(n,c)+Atot(n,c)+Rtot(n,c))*(DUoSrate+UnitRate); %Note Two Of these Values Should Always be 0
        HHchargewB(n,c) = (GtotwB(n,c)+AtotwB(n,c)+RtotwB(n,c))*(DUoSrate+UnitRate); %Note Two Of these Values Should Always be 0
    % Battery Degredation
           if batteryuse(n,c) >= 0 
           curCap2(c)=curCap2(c)-(batteryuse(n,c)*perCycleDeg/curCap2(c));
           Cap(n,c)=curCap2(c);
           use(c) = batteryuse(n,c)+use(c);
               if curCap2(c) <= use(c)
               cycle=cycle + 1;
               use(c) = use(c)-curCap2(c);
               end
           end
    end
    c=1440;
    
    batcaplast=batcap(1440);
    batcap=zeros(1,1440);
    batcap(1)=batcaplast;
    curCap2last=curCap2(1440);
    curCap2=zeros(1,1440);
    curCap2(1)=curCap2last;
    uselast=use(1440);
    use=zeros(1,1440);
    use(1)=uselast;
    

    DaychargewB(n,:)= sum(HHchargewB(n,:))./100; %Daily Cost in Pounds
    Daycharge(n,:)= sum(HHcharge(n,:))./100; %Daily Cost in Pounds
    if wkday > 0
    wkdaybattotuse(wkday,1)=sum(wkbatuse(wkday,:));
    end
% battotuse(n,1)=sum(batteryuse(n,:));
 waitbar((200-Cap(n,c))/ 40);  
end
runtime=toc;
% Display Savings
Yearcharge = sum(Daycharge);
YearchargewB = sum(DaychargewB);
Saving = Yearcharge-YearchargewB;
disp(['Total Saved = £' num2str(Saving)]);
close(h)
disp(['Years: ' num2str(n)]);
disp(['Cycles: ' num2str(cycle)]);
disp(['Run Time: ' num2str(runtime/60)]);
profile off
profile viewer