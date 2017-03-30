clc
clear
close all force
% profile clear
% profile on

%% Powerpack Calculation
UFCost=952660;
newCap=2380;
maxPower=1250;
				
%% Run Functions 
fileName = 'newCampus.csv'; %% Import Data File - Choose file here

samples=size(maxPower,1);
runlen=25;
ufcost=zeros(1,samples);
sizeRange=zeros(1,samples);
Year=zeros(1,samples);
totsaving=zeros(1,samples);
s= 1;

[livedatause, DataMatmm30, DataMat,sdate] = liveDatasingfunc(fileName); % Run data correction function to create demand profiles 
liveDataSelc= single(livedatause(1:365,:));
liveDataSelc(abs(liveDataSelc)<1e-2) = 0;
rowsDataSelec = size(liveDataSelc,1);

% VERTCAT to save time - need seven to remove errors with weekends
liveDataSelc1= vertcat(liveDataSelc(2:rowsDataSelec,:),liveDataSelc(2,:),liveDataSelc(3:rowsDataSelec,:),liveDataSelc(2:3,:),liveDataSelc(4:rowsDataSelec,:),liveDataSelc(2:4,:),liveDataSelc(5:rowsDataSelec,:),liveDataSelc(2:5,:),liveDataSelc(6:rowsDataSelec,:),liveDataSelc(2:6,:),liveDataSelc(7:rowsDataSelec,:),liveDataSelc(2:7,:),liveDataSelc);
  
for n=1:ceil(runlen/7) % Find Matrix Size
      liveDataSelc = vertcat(liveDataSelc,liveDataSelc1);
end


%% Variables
% set runlen to 0 for running battery until failure
tic
% Rates in Pence
UnitRate = 6.832;
rateR=24.41;
rateA=0.287;
rateG=0.161;
% [livedatause,DataMatmm30,DataMat,sdate] =liveDatafunc(fileName);

%% Battery Calculator
% % liveDataSelc= livedatause(1:365,:);
% liveDataSelc(abs(liveDataSelc)<1e-2) = 0;
rowsDataSelec = size(liveDataSelc,1);
colsDataSelec = size(liveDataSelc,2);
% liveDataSelc1= liveDataSelc;

Time=zeros(1,colsDataSelec);
for c = 1:1:colsDataSelec
    if colsDataSelec > 48
        Time(:,c) = c; %Minutes
    else
        Time(:,c) = c*30;
    end
end

loops= runlen; % Guess Number of years to speed up Process

  if colsDataSelec == 48
     liveDataDem=liveDataSelc;
  else
     liveDataDem = 2*30*liveDataSelc;
  end

% Powerwall Calculation
% UFCost = 86330;
% INCost = 0;
% mainCost = 0;
% newCap = 190; % kWH
% ppkWh = UFCost/newCap;
% maxPower=100;
% thermalDeg=0;
% OOBDeg=0;

% Set Charging rate based on 30% on max total power
doD = 0.8;
curCap = newCap;
maxCharge = ((1-doD)/2+doD)*curCap;
minCharge =((1-doD)/2)*curCap;
batCharge = maxCharge;

% Set Charging rate based on 20% on max total power
ChargeRate = maxPower*0.2*2; % Set in kWh per halfHour
if ChargeRate*24 < maxCharge
    disp('Charge Rate Too Slow')
end

% Create Time Period Size - Minutes or half Hour Period
if colsDataSelec ~= 48
    ChargeRate= ChargeRate/30;%  sets kWh per minute
    hhyn=1;
else
    hhyn=30;
end

batteryEff =0.92;
% half factor  7500 cycles for the next 20% dercrease Change both Cycles
% and end life
noCycles= 5000;
endlife= 0.8;
endlifeval=endlife*newCap;
perCycleDeg=(newCap-newCap*endlife)/noCycles;
use= 0;
cycle = 0;

year=1;
wkday=1;
dep = 0;
chrg = 0;
pbtime=[];

 % Guess Number of years to speed up Process
batteryuse = zeros(rowsDataSelec,colsDataSelec);
Rtot = zeros(rowsDataSelec,colsDataSelec);
Atot = zeros(rowsDataSelec,colsDataSelec);
Gtot = zeros(rowsDataSelec,colsDataSelec);
RtotwB = zeros(rowsDataSelec,colsDataSelec);
AtotwB = zeros(rowsDataSelec,colsDataSelec);
GtotwB = zeros(rowsDataSelec,colsDataSelec);
HHcharge = zeros(rowsDataSelec,colsDataSelec);
HHchargewB = zeros(rowsDataSelec,colsDataSelec);
% power=zeros(rowsDataSelec,colsDataSelec);
poweruse=zeros(rowsDataSelec,colsDataSelec);
overpower =zeros(rowsDataSelec,colsDataSelec);
Cap=zeros(rowsDataSelec,colsDataSelec);
wkbatuse=zeros(rowsDataSelec,colsDataSelec);
batcharge=zeros(rowsDataSelec,colsDataSelec);
cumSavings=zeros(rowsDataSelec,1);
powerwk=zeros(rowsDataSelec,colsDataSelec); %%POWER
batchargewk=zeros(rowsDataSelec,colsDataSelec); %% NEW
yearchargewB = zeros(1,loops);
yearcharge = zeros(1,loops);
SavingPY= zeros(1,loops);
cumSavyear=zeros(1,loops);
cumSavings(1)= -UFCost;
triadunitsave=zeros(loops,3);
triadcostsave=zeros(1,loops);
triadcost=zeros(1,loops);
accycle=0;

% Triad Information:
sdatechar=char(sdate);
sdatechar(sdatechar=='''') = [];
  try
    strtdate= datenum(sdatechar,'dd/mm/yyyy',2000);
  catch
     strtdate= datenum(sdatechar);
  end

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
triadrate= 33.55; % price per KW
nn=1;
tu=1;
dfs=0;
tn=zeros(loops,3);
triadunit=zeros(loops,3);
batful=zeros(1,loops);
daydep=zeros(rowsDataSelec,1);
daydepwk=zeros(rowsDataSelec,1);
n=0;
runyear=(runlen*365);

for n=1:1:runyear
trn=n-1;
    if trn < 365 % Find TRIAD Days and convert to days run in data
        dn=datestr(strtdate+trn);
        tday=0;
        if isequal(dn, t1) || isequal(dn, t2) ||isequal(dn, t3)
            tn(year,nn)=trn;
            nn=nn+1;
            tday=1;
        end

    elseif isequal(n, tn(year,1)) || isequal(n, tn(year,2)) || isequal(n, tn(year,3))
        tday=1;
    else
        tday=0;
    end

    

%     if rem((n)/365,1) == 0
%     set( get(findobj(h,'type','axes'),'title'), 'string',num2str(n/365))
%     end

    for c = 1:colsDataSelec
      batcharge(n,c)= batCharge;
        if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0
            day=2;
            if 990 < Time(1,c) && Time(1,c) <= 1170
              DUoSrate = rateA;
            else
              DUoSrate = rateG;
            end
        else
            day=1;
            if  Time(1,c) <= 1140 && Time(1,c) > 1020
                DUoSrate = rateR;
            elseif 480 < Time(1,c) && Time(1,c) <= 1020 || 1140 < Time(1,c) && Time(1,c) <= 1290
                DUoSrate = rateA;
            else
                DUoSrate = rateG;
            end
        end
        power=0;
        if DUoSrate == rateR
            if liveDataDem(n,c) > maxPower
                overpower(n,c)= (maxPower/liveDataDem(n,c))*liveDataSelc(n,c);
                power= maxPower; %%%% POWER
            else
                overpower(n,c) = liveDataSelc(n,c);
                power= liveDataDem(n,c); %%%%% POWER 
            end
            if  batcharge(n,c)- minCharge <= overpower(n,c)
                batteryuse(n,c)= minCharge-batcharge(n,c);
            else
                batteryuse(n,c)= -overpower(n,c);
            end
            daydep(n,c)=batteryuse(n,c); %%% NEW
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
%              if batteryuse(n,c) < 0 %%% P
%                 poweruse(n,c)=power;%%%%% POWER 
%              end
             Cap(n,c)=curCap;
             HHchargewB(n,c) = (liveDataSelc(n,c)+batteryuse(n,c))*(DUoSrate+UnitRate);
            
         end

        if  day==1
            wkbatuse(wkday,c) = batteryuse(n,c);
            powerwk(wkday,c)= power;
            batchargewk(wkday,c) = Cap(n,c);
            if batteryuse(n,c) < 0
            daydepwk(wkday,c)=batteryuse(n,c);
            end
        end

        HHcharge(n,c) = (liveDataSelc(n,c))*(DUoSrate+UnitRate);

        if tday == 1 && c == 1050/hhyn
            if liveDataDem(n,c) > maxPower
                triadunitsave(year,tu) = maxPower;
            else
                triadunitsave(year,tu) = liveDataDem(n,c);
            end
            triadunit(year,tu)= liveDataDem(n,c);
            tu= tu+1;
        end

    end

   if year > 1 % USING TRIAD RATES of Previous Year Distributed Evenly
        cumSavings(n+1,:)= cumSavings(n,:)+((sum(sum(HHcharge(n,1:colsDataSelec)))-sum(sum(HHchargewB(n,1:colsDataSelec))))./100)+triadcostsave(year)/365;
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
        yearchargewB(year) = sum(sum(HHchargewB(n-364:n,1:colsDataSelec)),2)./100;
        yearcharge(year) = sum(sum(HHcharge(n-364:n,1:colsDataSelec)),2)./100;
         % For Triads
         % TAKES TRIAD Of Previous Year and applies equally over the next year.
        tn(year+1,:)=tn(year,:)+364-dfs; % 364 so always falls on the same day % dfs if needing to adjust
        triadcost(year+1) = triadrate*(triadunit(year,1) +triadunit(year,2) + triadunit(year,3))/3; % Tells The actual Cost of the TRIAD
        triadcostsave(year+1) = triadrate*(triadunitsave(year,1) +triadunitsave(year,2) + triadunitsave(year,3))/3; % Tells the amount saved by using the battery
        tu=1;
        SavingPY(year)= yearcharge(year)-yearchargewB(year)+triadcostsave(year);
        year = year + 1;
    end

%       if rem((n)/365,1) == 0 || rem((n)/182,1) == 0
%           waitbar((newCap-Cap(n,c))/ (newCap-endlifeval));
%       end

%      if n == runlen*365
%         break
     if curCap < endlifeval && isequal(accycle,0)
        accycle= cycle;
     end
end
runtime=toc;
% DaychargewB= (sum(HHchargewB')./100)'; %Daily Cost in Pounds
% Daycharge= (sum(HHcharge')./100)'; %Daily Cost in Pounds
% triadtotcost=sum(triadcost(1:year));
% lifecharge = sum(Daycharge);
% lifechargewB = sum(DaychargewB);
% Saving = lifecharge-lifechargewB+triadtotcost;


Cap(n:size(Cap,1),:)=[];
if isequal(accycle,0)
    accycle= cycle;
    capex=n;
else
capex=find(Cap(:,1140)<endlifeval);
end

if capex(1) == 1
capex2=capex(2);
else
capex2=capex(1);
end
capexwk=find(batchargewk(:,1140)<endlifeval);
if capexwk(1) == 1
capexwk2=capexwk(2);
else
capexwk2=capexwk(1);
end


% cumSavings(n:size(cumSavings,1),:)=[];
cumSavings(capex2:size(cumSavings,1),:)=[];
tt=1;
for t = 1:365:capex2-1
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

% daydepwk(wkday:size(daydepwk,1),:)=[];
% batchargewk(wkday:size(batchargewk,1),:)=[];
% powerwk(wkday:size(powerwk,1),:)=[];
daydepwk(capexwk2:size(daydepwk,1),:)=[];
batchargewk(capexwk2:size(batchargewk,1),:)=[];
powerwk(capexwk2:size(powerwk,1),:)=[];


powerwktime=sum(powerwk~=0,2);%%%%% POWER 
powerwksum=sum(powerwk,2);%%%%% POWER 
avpower=powerwksum./powerwktime;%%%%% POWER 

daydepsumwk=sum(daydepwk,2);
batchargebdwk=batchargewk(:,1020);
Crateav=avpower./batchargebdwk;%%%%% POWER 
Dischargetime=1./Crateav;%%%%% POWER 
disTmean=mean(Dischargetime);

DODwk=abs((daydepsumwk./batchargebdwk))*100;
DoDmean=mean(DODwk);
Year=capex2/365;

disp(['Mean DoD: ',num2str(DoDmean),'%']);
disp(['Mean Discharge Time: ',num2str(disTmean),' Hours']);
disp(['Battery Specifications - P: ', num2str(maxPower), ' C: ', num2str(newCap)]);
disp(['Total Saved P ' num2str(Saving)]);
disp(['Payback Period: ' num2str(pbtime) ' Years']);
disp(['Years: ' num2str(Year)]);
disp(['Cycles: ' num2str(accycle)]);
disp(['Run Time: ' num2str(runtime) ' Seconds']);

% plot((1:365:n-1)/365,cumSavyear);
% title('Payback Period For Battery')
% xlabel('Time / Years')
% ylabel('Cumlative Savings / �)

% profile off
% profile viewer