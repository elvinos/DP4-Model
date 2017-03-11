clear all
close all force
clc

fileName='senateEDD.csv';
UFCost=90000;
newCap= 190;
maxPower=100;
runlen=40;
%% Variables
% set runlen to 0 for running battery until failure
% Rates in Pence
UnitRate = 6.832;
rateR=24.41;
rateA=0.287;
rateG=0.161;
[livedatause,DataMatmm30,DataMat,sdate] =liveDatafunc(fileName);

%% Battery Calculator
liveDataSelc= livedatause(1:365,:);
liveDataSelc(abs(liveDataSelc)<1e-2) = 0;
rowsDataSelec = size(liveDataSelc,1);
colsDataSelec = size(liveDataSelc,2);
liveDataSelc1= liveDataSelc;

% liveDataSelc1= vertcat(liveDataSelc(2:rowsDataSelec,:),liveDataSelc(2,:),liveDataSelc(3:rowsDataSelec,:),liveDataSelc(2:3,:),liveDataSelc(4:rowsDataSelec,:),liveDataSelc(2:4,:),liveDataSelc(5:rowsDataSelec,:),liveDataSelc(2:5,:),liveDataSelc(6:rowsDataSelec,:),liveDataSelc(2:6,:),liveDataSelc(7:rowsDataSelec,:),liveDataSelc(2:7,:),liveDataSelc);

for c = 1:1:colsDataSelec
    if colsDataSelec > 48
        Time(:,c) = c; %Minutes
    else
        Time(:,c) = c*30;
    end
end

loops= runlen; % Guess Number of years to speed up Process
% for j = 1:ceil(loops/7)
% liveDataSelc = vertcat(liveDataSelc,liveDataSelc1);
%  if colsDataSelec == 48
%     liveDataDem=liveDataSelc;
%  else
%      liveDataDem = 2*29.995*liveDataSelc;
%  end
% end
  for n=1:ceil(loops/7)
        for gg= 2:7
             liveDataSelc = vertcat(liveDataSelc,liveDataSelc1(gg:rowsDataSelec,:),liveDataSelc1(2:gg,:));
        end
         liveDataSelc = vertcat(liveDataSelc,liveDataSelc1);
  end
  
  if colsDataSelec == 48
     liveDataDem=liveDataSelc;
  else
     liveDataDem = 2*29.995*liveDataSelc;
  end

% Powerwall Calculation
% UFCost = 86330;
% INCost = 0;
% mainCost = 0;
% newCap = 190; % kWH
% ppkWh = UFCost/newCap;
doD = 0.8;
curCap = newCap;
maxCharge = ((1-doD)/2+doD)*curCap;
minCharge =((1-doD)/2)*curCap;
batCharge = maxCharge;
% maxPower=100;
% thermalDeg=0;
% OOBDeg=0;
ChargeRate = 15; % Set in kWh per halfHour

    if colsDataSelec ~= 48
       ChargeRate= 15/30;%  sets kWh per minute
    end

batteryEff =0.92;
noCycles= 5000;
endlife= 0.8;
endlifeval=endlife*newCap;
perCycleDeg=(newCap-newCap*endlife)/noCycles;
use= 0;
cycle = 0;
n=0;
year=1;
wkday=1;
dep = 0;
chrg = 0;
pbtime=[];

 % Guess Number of years to speed up Process
batteryuse = zeros(rowsDataSelec*loops,colsDataSelec);
Rtot = zeros(rowsDataSelec*loops,colsDataSelec);
Atot = zeros(rowsDataSelec*loops,colsDataSelec);
Gtot = zeros(rowsDataSelec*loops,colsDataSelec);
RtotwB = zeros(rowsDataSelec*loops,colsDataSelec);
AtotwB = zeros(rowsDataSelec*loops,colsDataSelec);
GtotwB = zeros(rowsDataSelec*loops,colsDataSelec);
HHcharge = zeros(rowsDataSelec*loops,colsDataSelec);
HHchargewB = zeros(rowsDataSelec*loops,colsDataSelec);
overpower =zeros(rowsDataSelec*loops,colsDataSelec);
Cap=zeros(rowsDataSelec*loops,colsDataSelec);
wkbatuse=zeros(rowsDataSelec*loops,colsDataSelec);
batcharge=zeros(rowsDataSelec*loops,colsDataSelec);
cumSavings=zeros(rowsDataSelec*loops,1);
yearchargewB = zeros(1,loops);
yearcharge = zeros(1,loops);
SavingPY= zeros(1,loops);
cumSavyear=zeros(1,loops);
cumSavings(1)= -UFCost;
triadcost=zeros(1,loops);
triadcost(1)=0;
% Triad Information:
strtdate= datenum(char(sdate),'dd/mm/yyyy',2000);
t1='04-Dec-2014';
t2='19-Jan-2015';
t3='02-Feb-2015';
if datenum(t1) < strtdate
    [Y,M,D] = datevec(strtdate);
    [Y1,M1,D1] = datevec(t1);
    [Y2,M2,D2] = datevec(t2);
    [Y3,M3,D3] = datevec(t3);
    t1 = datestr(datenum(Y,M1,D1)); 
    t2 = datestr(datenum(Y+1,M2,D2));
    t3 = datestr(datenum(Y+1,M3,D3)); 
end
triadrate= 33.55; % £ per KW
nn=1;
tu=1;
dfs=0;
tn=zeros(1,3);
triadunit=zeros(loops,3);


h = waitbar(0,'Please wait...');
tic

while curCap > endlifeval
    
    if n < 365 % Find TRIAD Days
        dn=datestr(strtdate+n);
        tday=0;
        if isequal(dn, t1) || isequal(dn, t2) ||isequal(dn, t3)
            tn(nn)=n;
            nn=nn+1;
            tday=1;
        end
    elseif isequal(n, tn(1)) || isequal(n, tn(2)) || isequal(n, tn(3))
        tday=1;
    else
        tday=0;
    end
    
    n = n+1;
    
    if rem((n)/365,1) == 0 
    set( get(findobj(h,'type','axes'),'title'), 'string',num2str(n/365))
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
            if liveDataDem(n,c) > maxPower
                overpower(n,c)= (maxPower/liveDataDem(n,c))*liveDataSelc(n,c);
            else
                overpower(n,c) = liveDataSelc(n,c);
            end
            if batcharge(n,c)-minCharge <= overpower(n,c)
                batteryuse(n,c)= minCharge-batcharge(n,c);
            else
                batteryuse(n,c)= -overpower(n,c);
            end
       
            dep = dep+batteryuse(n,c);
            Rtot(n,c)= liveDataSelc(n,c);
            RtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
        elseif DUoSrate == rateA
          Atot(n,c)= liveDataSelc(n,c);
          AtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c));
        elseif DUoSrate == rateG
            if batcharge(n,c) < maxCharge
                if maxCharge-batcharge(n,c) <= ChargeRate
                  batteryuse(n,c)= maxCharge-batcharge(n,c);
                  if batteryuse(n,c) ~= 0
                      batteryuse(n,c)=batteryuse(n,c)-batteryuse(n,c);
                  end
                else
                  batteryuse(n,c) = ChargeRate;
                end
            end
            chrg= chrg+batteryuse(n,c);
            Gtot(n,c)= liveDataSelc(n,c);
            GtotwB(n,c)= (liveDataSelc(n,c)+batteryuse(n,c)*(1/batteryEff)); %Added Losses in Bat Efficiency
        
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
        
        HHcharge(n,c) = (liveDataSelc(n,c))*(DUoSrate+UnitRate);
        
        if tday == 1 && c == 1050
            if liveDataDem(n,c) > maxPower
                triadunit(year,tu) = maxPower;
            else
                triadunit(year,tu)=liveDataDem(n,c);
            end
            tu= tu+1;
        end
        
    end
    
   if year > 1 % USING TRIAD RATES of Previous Year Distributed Evenly
        cumSavings(n+1,:)= cumSavings(n,:)+((sum(sum(HHcharge(n,1:colsDataSelec)))-sum(sum(HHchargewB(n,1:colsDataSelec))))./100)+triadcost(year)/365;
   else
        cumSavings(n+1,:)= cumSavings(n,:)+(sum(sum(HHcharge(n,1:colsDataSelec)))-sum(sum(HHchargewB(n,1:colsDataSelec))))./100;
   end
    if  cumSavings(n+1,:) > 0 && isempty(pbtime)
        pbtime = n;
    end


        if  day==1
            wkday = wkday+1;        
        end

    if rem((n)/365,1) == 0
        yearchargewB(year) = sum(sum(HHchargewB(n-364:n,1:colsDataSelec))');
        yearcharge(year) = sum(sum(HHcharge(n-364:n,1:colsDataSelec))');
         % For Triads
        triadcost(year+1) = triadrate*(triadunit(year,1) +triadunit(year,2) + triadunit(year,3))/3; 
        tn=tn+364-dfs;
        tu=1;
        SavingPY(year)= yearcharge(year)-yearchargewB(year)+triadcost(year);
        year = year + 1;
    end
     
      if rem((n)/365,1) == 0 || rem((n)/182,1) == 0
          waitbar((newCap-Cap(n,c))/ (newCap-endlifeval));
      end
      
      if n == runlen*365
        break
      end      
end
runtime=toc;
% DaychargewB= (sum(HHchargewB')./100)'; %Daily Cost in Pounds
% Daycharge= (sum(HHcharge')./100)'; %Daily Cost in Pounds
% triadtotcost=sum(triadcost(1:year));
% lifecharge = sum(Daycharge);
% lifechargewB = sum(DaychargewB);
% Saving = lifecharge-lifechargewB+triadtotcost;

cumSavings(n:size(cumSavings,1),:)=[];
tt=1;
for t = 1:365:n-1
    cumSavyear(tt)=cumSavings(t);
%     yearT(tt)=tt-1;
    tt=tt+1;
end
% yearT(:,(tt:size(cumSavyear,2)))=[];
cumSavyear(:,(tt:size(cumSavyear,2)))=[];
Saving = cumSavyear(1,size(cumSavyear,2));
if isempty(pbtime)
    pbtime = 0;
end
pbtime = pbtime/365;
close(h)
disp(['Battery Specifications - P: ', num2str(maxPower), ' C: ', num2str(newCap)]);
disp(['Total Saved P ' num2str(Saving)]);
disp(['Payback Period: ' num2str(pbtime) ' Years']);
disp(['Years: ' num2str(n/365)]);
disp(['Cycles: ' num2str(cycle)]);
disp(['Run Time: ' num2str(runtime) ' Seconds']);




% plot((1:365:n-1)/365,cumSavyear);
% title('Payback Period For Battery')
% xlabel('Time / Years')
% ylabel('Cumlative Savings / £')