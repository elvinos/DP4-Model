%% Clear And Close
clc
clear
close all force
% profile clear
% profile on

%% Powerpack Calculation
ppFileName = 'Powerpackprice2.csv';
[maxPower,newCap,UFCost] = powerpackpricesing(ppFileName);

%% Run Functions
fileName = 'newCampus.csv'; %% Import Data File - Choose file here

maxPower=maxPower(18);
newCap=newCap(18);
UFCost=UFCost(18);
samples=size(maxPower,1);
runlen=25;
ufcost=zeros(1,samples);
sizeRange=zeros(1,samples);
pbtime=zeros(1,samples);
Year=zeros(1,samples);
Saving=zeros(1,samples);
totsaving=zeros(1,samples);
DoDmean=zeros(1,samples);
disTmean=zeros(1,samples);
cycle=zeros(1,samples);
s= 1;

hh = parfor_progressbar(samples,'Please wait...'); %create the progress bar

tic
[livedatause, DataMatmm30, DataMat,sdate] = liveDatasingfunc(fileName); % Run data correction function to create demand profiles
liveDataSelc= livedatause(1:365,:);
liveDataSelc(abs(liveDataSelc)<1e-2) = 0;
rowsDataSelec = size(liveDataSelc,1);

% VERTCAT to save time - need seven to remove errors with weekends
liveDataSelc1= vertcat(liveDataSelc(2:rowsDataSelec,:),liveDataSelc(2,:),liveDataSelc(3:rowsDataSelec,:),liveDataSelc(2:3,:),liveDataSelc(4:rowsDataSelec,:),liveDataSelc(2:4,:),liveDataSelc(5:rowsDataSelec,:),liveDataSelc(2:5,:),liveDataSelc(6:rowsDataSelec,:),liveDataSelc(2:6,:),liveDataSelc(7:rowsDataSelec,:),liveDataSelc(2:7,:),liveDataSelc);

for n=1:ceil(runlen/7) % Find Matrix Size
      liveDataSelc = vertcat(liveDataSelc,liveDataSelc1);
end

for s = 1:samples % Loop to find results for all batteries
[cumSavyear,Year(s),Saving(s),pbtime(s),SavingPY(s,:),DoDmean(s),disTmean(s),cycle(s)] = dlivsgforfunc(liveDataSelc,sdate,UFCost(s), newCap(s), maxPower(s));% battery running function
totsaving(s)= cumSavyear(1,size(cumSavyear,2));% Create total savings from cumlative savings array
hh.iterate(1); % Parallel
set(get(findobj(hh,'type','axes'),'title'), 'string',['Sample ', num2str(s), ' of ', num2str(samples) ])
end

totsaving=double(totsaving');
pbtime=double(pbtime');
CashFlow=horzcat(-UFCost,SavingPY); % add year 0 value to cash flow
disrates=[0.03,0.07,0.12];
npvRates=struct('Rate1', disrates(1),'Rate2', disrates(2),'Rate3', disrates(3)); %% Select NPV Rates
npf=3; %% Select polynomical fit for curves
close(hh)

set(0,'DefaultFigureWindowStyle','docked') %% Dock all figures
set(0,'defaultfigurecolor',[1 1 1]) % Set bacground colour to white
set(0,'DefaultAxesFontSize', 12)
set(0,'DefaultTextFontSize', 14)
%% Plots

toc



for ss= 1:samples
%     Labels1{ss}=strcat('P: ', num2str(maxPower(ss,1)));
%     Labels2{ss} = strcat('P: ', num2str(maxPower(ss,1)), ' PB: ', num2str(pbtime(ss)));
    npv1(ss,:)=double(pvvar(CashFlow(ss,:),npvRates.Rate1));
    npv2(ss,:)=double(pvvar(CashFlow(ss,:),npvRates.Rate2));
    npv3(ss,:)=double(pvvar(CashFlow(ss,:),npvRates.Rate3));
%     Labels5{ss}=strcat('P: ', num2str(maxPower(ss,1)));
%     Labels6{ss}=strcat('P: ', num2str(maxPower(ss,1)));
%     Labels7{ss}=strcat('P: ', num2str(maxPower(ss,1)));
%     Labels8{ss}=strcat('C: ', num2str(sizeRange(ss,1)));
end

allNPV=horzcat(npv1,npv2,npv3);

MeanDoD=DoDmean';
MeanDischargeTime=disTmean';
Years=Year';
Cycles=cycle';

fitDoD=[0.00005717	-0.013850197	1.265097548	-53.62121894	1013.656987];
fitDisT=[0.0056	-0.0792	0.383	0.358];
EffectofDoD=(MeanDoD.^4.*fitDoD(1)+MeanDoD.^3.*fitDoD(2)+MeanDoD.^2.*fitDoD(3)+MeanDoD.*fitDoD(4)+fitDoD(5))./100;
EffectofDisT=MeanDischargeTime.^3.*fitDisT(1)+MeanDischargeTime.^2.*fitDisT(2)+MeanDischargeTime.*fitDisT(3)+fitDisT(4);
TotalDegOffset=EffectofDoD.*EffectofDisT;
ActualLife=5000*TotalDegOffset;

[minPBtime, Inpb] = min(pbtime(pbtime>0));
[maxSave, Inms] = max(totsaving);
[maxNpv1, Inmn1] = max(npv1);
[maxNpv2, Inmn2] = max(npv2);
[maxNpv3, Inmn3] = max(npv3);

disp(['Best PB Time: ', num2str(minPBtime), ' P:' num2str(maxPower(Inpb)),  'C: ' num2str(newCap(Inpb))]);
disp(['Maximum Savings: ', num2str(maxSave), ' P:' num2str(maxPower(Inms)),  'C: ' num2str(newCap(Inms))]);
disp(['Max Net Present Value 3%: ', num2str(maxNpv1), ' P:' num2str(maxPower(Inmn1)),  'C: ' num2str(newCap(Inmn1))]);
disp(['Max Net Present Value 7%: ', num2str(maxNpv2), ' P:' num2str(maxPower(Inmn2)),  'C: ' num2str(newCap(Inmn2))]);
disp(['Max Net Present Value 12%: ', num2str(maxNpv3), ' P:' num2str(maxPower(Inmn3)),  'C: ' num2str(newCap(Inmn3))]);


Resultstab=table(maxPower,newCap,UFCost,totsaving,pbtime,allNPV,Years,Cycles,MeanDoD,MeanDischargeTime,EffectofDoD,EffectofDisT,TotalDegOffset,ActualLife);
