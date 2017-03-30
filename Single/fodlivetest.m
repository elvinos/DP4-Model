clc
clear
close all force
% profile clear
% profile on

%% Powerpack Calculation
% UFCost=[226260,196380,233060];
% newCap=[570,480,570];
% maxPower=[200,250,300];

%% Powerpack Calculation
ppFileName = 'Powerpackprice.csv';
[maxPower,newCap,UFCost] = powerpackprice(ppFileName);
maxPower=maxPower(10:15,1)';
newCap=newCap(10:15,1)';
UFCost=UFCost(10:15,1)';
% mP=maxPower';
% nC=newCap';
% uC=UFCost';

% maxPower=maxPower(18);
% newCap=newCap(18);
% UFCost=UFCost(18);

%% Run Functions 
fileName = 'newCampus.csv'; %% Import Data File - Choose file here

samples=size(maxPower,2);
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
% SavingPY=zeros(runlen,samples);
% s= 1;

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
[cumSavyear,Year(s),Saving(s),pbtime(s),SavingPY(s,:),DoDmean(s),disTmean(s),cycle(s)]=dlivsgforfunc(liveDataSelc,sdate,UFCost(s), newCap(s), maxPower(s));% battery running function 
totsaving(s)= cumSavyear(1,size(cumSavyear,2));% Create total savings from cumlative savings array
end