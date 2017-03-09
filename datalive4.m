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
% fileName = 'senateEDD.csv';
% Data=senateEDD1(fileName);
% rowsData= size(Data,1);
% colsData= size(Data,2);
% DataMat = cell2mat(Data(2:rowsData,4:colsData));
rnfit=2;
[livedata,DataMatmm30,DataMat] =liveDatafunc(rnfit);

%% Battery Calculator
liveDataSelc= DataMat;
liveDataSelc(abs(liveDataSelc)<1e-2) = 0;
rowsDataSelec = size(liveDataSelc,1);
colsDataSelec = size(liveDataSelc,2);
liveDataSelc1= vertcat(liveDataSelc(2:rowsDataSelec,:),liveDataSelc(2,:),liveDataSelc(3:rowsDataSelec,:),liveDataSelc(2:3,:),liveDataSelc(4:rowsDataSelec,:),liveDataSelc(2:4,:),liveDataSelc(5:rowsDataSelec,:),liveDataSelc(2:5,:),liveDataSelc(6:rowsDataSelec,:),liveDataSelc(2:6,:),liveDataSelc(7:rowsDataSelec,:),liveDataSelc(2:7,:),liveDataSelc);

for c = 1:1:colsDataSelec
    if colsDataSelec > 48
        Time(:,c) = c; %Minutes
    else
        Time(:,c) = c*30;
        TimeH(:,c) = c/2; % Hours
    end
end

loops= 60; % Guess Number of years to speed up Process
kwhcost = 500;
batteryuse = zeros(rowsDataSelec*loops,colsDataSelec);
wkday = 0;
Rtot = zeros(rowsDataSelec*loops,colsDataSelec);
Atot = zeros(rowsDataSelec*loops,colsDataSelec);
Gtot = zeros(rowsDataSelec*loops,colsDataSelec);
RtotwB = zeros(rowsDataSelec*loops,colsDataSelec);
AtotwB = zeros(rowsDataSelec*loops,colsDataSelec);
GtotwB = zeros(rowsDataSelec*loops,colsDataSelec);
% batteryuse2 = zeros(rowsDataMatmm30*loops,colsDataMatmm30);
DUoSCharge = zeros(rowsDataSelec*loops,colsDataSelec);
DUoSChargewB = zeros(rowsDataSelec*loops,colsDataSelec);
HHcharge = zeros(rowsDataSelec*loops,colsDataSelec);
HHchargewB = zeros(rowsDataSelec*loops,colsDataSelec);
% Daycharge=zeros(rowsDataMatmm30*loops,1);
Cap=zeros(rowsDataSelec*loops,colsDataSelec);
wkbatuse=zeros(rowsDataSelec*loops,colsDataSelec);
batcharge=zeros(rowsDataSelec*loops,colsDataSelec);
cumSavings=zeros(rowsDataSelec*loops,1);

% Powerwall Calculation
UFCost = 86330;
INCost = 0;
mainCost = 0;
newCap = 200; % kWH
ppkWh = UFCost/newCap;
doD = 0.8;
curCap = newCap;
maxCharge = ((1-doD)/2+doD)*curCap;
minCharge =((1-doD)/2)*curCap;
batCharge = maxCharge;

thermalDeg=0;
OOBDeg=0;
ChargeRate = 15; % Set in kWh per halfHour

    if colsDataSelec ~= 48
       ChargeRate= 15/30;%  sets kWh per minute
    end

batteryEff =0.92;

noCycles= 5000;
endlife= 0.6;
endlifeval=endlife*newCap;
perCycleDeg=(newCap-newCap*endlife)/noCycles;
y= 1;
use= 0;
cycle = 0;
n=0;
year=1;
wk = 1;
wkday=1;
dep = 0;
chrg = 0;
cumSavings(1)= -UFCost;
pbtime=[];

h = waitbar(0,'Please wait...');
tic

while curCap > endlifeval
    n = n+1;

    if rem((n)/365,1) == 0
    set( get(findobj(h,'type','axes'),'title'), 'string',num2str(n/365))
    end
   
    if n == 1 || rem((n)/2555,1) == 0
    liveDataSelc = vertcat(liveDataSelc,liveDataSelc1);
    end
    
    for c = 1:colsDataSelec
      batcharge(n,c)= batCharge;
        if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0
            day=2;
            if 17*60 < Time(1,c) && Time(1,c) <= 19.5*60
              DUoSrate = rateA;
            else
              DUoSrate = rateG;
            end
        else
            day=1;
            if  Time(1,c) <= 19*60 && Time(1,c) > 17*60
                DUoSrate = rateR;
            elseif 8*60 < Time(1,c) && Time(1,c) <= 17*60 || 19*60 < Time(1,c) && Time(1,c) <= 21.5*60
                DUoSrate = rateA;
            else
                DUoSrate = rateG;
            end
        end

        if DUoSrate == rateR
            if batcharge(n,c)-minCharge <= liveDataSelc(n,c)
                batteryuse(n,c)= minCharge-batcharge(n,c);
%                 disp(['deplete ', num2str(batteryuse(n,c)), ' Day ', num2str(n), ' Min ', num2str(c)])
            else
                batteryuse(n,c)= -liveDataSelc(n,c);

            end
            dep = dep+batteryuse(n,c);
            Rtot(n,c)= liveDataSelc(n,c);
            RtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
        elseif DUoSrate == rateA
          % batteryuse(n,c)=0;
          Atot(n,c)= liveDataSelc(n,c);
          AtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
        elseif DUoSrate == rateG
            if batcharge(n,c) < maxCharge
                if maxCharge-batcharge(n,c) <= ChargeRate
                  batteryuse(n,c)= maxCharge-batcharge(n,c);
                  if batteryuse(n,c) ~= 0
                      batteryuse(n,c)=batteryuse(n,c)-batteryuse(n,c);
%                     disp(['trickle charge ', num2str(sum(sum(batteryuse))), ' Day ', num2str(n), ' Min ', num2str(c)])
                  end
                else
                  batteryuse(n,c) = ChargeRate;
                end
            end
            chrg= chrg+batteryuse(n,c);
            Gtot(n,c)= liveDataSelc(n,c);
            GtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c)*(1/batteryEff)); %Added Losses in Bat Efficiency
          else
            disp('hhmmm')
        end
        batCharge=batCharge+batteryuse(n,c);

         if batteryuse(n,c) > 0
               curCap=curCap-(batteryuse(n,c)*perCycleDeg/curCap);
               Cap(n,c)=curCap;
               use = batteryuse(n,c)+use;
               if curCap <= use
                   cycle=cycle + 1;
                   use = use-curCap;
               end
               maxCharge = ((1-doD)/2+doD)*curCap;
               minCharge =((1-doD)/2)*curCap; 
               HHchargewB(n,c) = (liveDataSelc(n,c)+batteryuse(n,c)*(1/batteryEff))*(DUoSrate+UnitRate); %Added Losses in Bat Efficiency
         else 
             Cap(n,c)=curCap;
             HHchargewB(n,c) = (liveDataSelc(n,c)+batteryuse(n,c))*(DUoSrate+UnitRate);
         end
         
        if  day==1
            wkbatuse(wkday,c) = batteryuse(n,c);
        end

%       DUoSCharge(n,c)= (Gtot(n,c)+Atot(n,c)+Rtot(n,c))*DUoSrate;
%       DUoSChargewB(n,c)= (GtotwB(n,c)+AtotwB(n,c)+RtotwB(n,c))*DUoSrate; %Note Two Of these Values Should Always be 0
        HHcharge(n,c) = (liveDataSelc(n,c))*(DUoSrate+UnitRate);
     
    end
    
   
    cumSavings(n+1,:)= cumSavings(n,:)+(sum(sum(HHcharge(n,1:colsDataSelec)))-sum(sum(HHchargewB(n,1:colsDataSelec))))./100;
    if cumSavings(n+1,:) > 0 && isempty(pbtime)
        pbtime = n;
    end
     
    if rem((n)/365,1) == 0 || rem((n)/182,1) == 0
      waitbar((newCap-Cap(n,c))/ (newCap-endlifeval));
    end

        if  day==1
            wkday = wkday+1;        
        end

    if rem((n)/7,1) == 0
        batweekuse(wk)= sum(sum(batteryuse(n-6:n,1:colsDataSelec)));
        wk= wk+1;
    end

    if rem((n)/365,1) == 0
        yearchargewB(year) = sum(sum(HHchargewB(n-364:n,1:colsDataSelec))');
        yearcharge(year) = sum(sum(HHcharge(n-364:n,1:colsDataSelec))');
        SavingPY(year)= yearcharge(year)-yearchargewB(year);
        batCharge2(year)= Cap(n,colsDataSelec)';
        RtotwB2(year)= sum(sum(RtotwB(n-364:n,1:colsDataSelec)))';
        Rtot2(year)= sum(sum(Rtot(n-364:n,1:colsDataSelec))');
        batuse2(year)= sum(sum(batteryuse(n-364:n,1:colsDataSelec)))';
        year = year + 1;
    end

% %         if n >= 105
% %             break
% %         end

end
runtime=toc;
DaychargewB= (sum(HHchargewB')./100)'; %Daily Cost in Pounds
Daycharge= (sum(HHcharge')./100)'; %Daily Cost in Pounds

lifecharge = sum(Daycharge);
lifechargewB = sum(DaychargewB);
Saving = lifecharge-lifechargewB;
close(h)
disp(['Total Saved P ' num2str(Saving)]);
disp(['Payback Period: ' num2str(pbtime/365) ' Years']);
disp(['Years: ' num2str(n/365)]);
disp(['Cycles: ' num2str(cycle)]);
disp(['Run Time: ' num2str(runtime) ' Seconds']);

% batcharge(n:size(batcharge,1),:)=[];
% batteryuse(n:size(batteryuse,1),:)=[];

%% Plots
cumSavings(n:size(cumSavings,1),:)=[];
tt=1;
for t = 1:365:n-1
    cumSavyear(tt)=cumSavings(t);
    tt=tt+1;
end

plot((1:365:n-1)/365,cumSavyear)
title('Payback Period For Battery')
xlabel('Time / Years')
ylabel('Cumlative Savings / �')


% filename = 'BatUse';
% xlswrite(filename,batteryuse,'Sheet 1','A1')
% profile off
%
% profile viewer
