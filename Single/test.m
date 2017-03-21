%% Clear And Close
clc
clear
close all force
profile clear
profile on

%% Powerpack Calculation
ppFileName = 'Powerpackprice2.csv';
[batparam] = powerpackpricesing(ppFileName);

%% Next
fileName = 'newCampus.csv';

samples=size(batparam.maxPower,1);
runlen=25;
ufcost=zeros(1,samples);
sizeRange=zeros(1,samples);
pbtime=zeros(1,samples);
Year=zeros(1,samples);
Saving=zeros(1,samples);
totsaving=zeros(1,samples);
s= 1;

hh = parfor_progressbar(samples,'Please wait...'); %create the progress bar 

tic
[datafile] = liveDatasingfunc(fileName);
liveDataSelc= single(datafile.livedatause(1:365,:));
liveDataSelc(abs(liveDataSelc)<1e-2) = 0;
rowsDataSelec = size(liveDataSelc,1);
colsDataSelec = size(liveDataSelc,2);
liveDataSelc1= vertcat(liveDataSelc(2:rowsDataSelec,:),liveDataSelc(2,:),liveDataSelc(3:rowsDataSelec,:),liveDataSelc(2:3,:),liveDataSelc(4:rowsDataSelec,:),liveDataSelc(2:4,:),liveDataSelc(5:rowsDataSelec,:),liveDataSelc(2:5,:),liveDataSelc(6:rowsDataSelec,:),liveDataSelc(2:6,:),liveDataSelc(7:rowsDataSelec,:),liveDataSelc(2:7,:),liveDataSelc);
  for n=1:ceil(runlen/7)
      liveDataSelc = vertcat(liveDataSelc,liveDataSelc1);
  end

parfor s = 1:samples
[cumSavyear,Year(s),Saving(s),pbtime(s),SavingPY(s,:),DoDmean(s)] = datalivesingfunc(liveDataSelc,datafile.sdate,batparam.UFCost(s), batparam.newCap(s), batparam.maxPower(s),runlen);
totsaving(s)= cumSavyear(1,size(cumSavyear,2));
hh.iterate(1); % Parallel
set( get(findobj(hh,'type','axes'),'title'), 'string',['Sample ', num2str(s), ' of ', num2str(samples) ])
end

profile off

profile viewer