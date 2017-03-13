%% Clear And Close
clc
clear all
close all force
% profile clear
% profile on

%% Powerpack Calculation
ppFileName = 'Powerpackprice2.csv';
[maxPower,newCap,UFCost] = powerpackprice(ppFileName);

fileName = 'newCampus1.csv';
samples=size(maxPower,1);
runlen=25;

ufcost=zeros(1,samples);
sizeRange=zeros(1,samples);
pbtime=zeros(1,samples);
Year=zeros(1,samples);
Saving=zeros(1,samples);
totsaving=zeros(1,samples);
s= 1;

hh = parfor_progressbar(samples,'Please wait...'); %create the progress bar 
% hh = waitbar(0,'Please wait...'); Non Paralell
tic
% for newCap = minSize:step:maxSize
parfor s = 1:samples
[cumSavyear,Year(s),Saving(s),pbtime(s),SavingPY(s,:)] = datalivefunc(fileName,UFCost(s), newCap(s), maxPower(s),runlen);
totsaving(s)= cumSavyear(1,size(cumSavyear,2));
%waitbar(s/(samples)); % Non Parallel
% s= s+1; % Non Parallel
hh.iterate(1); % Parallel
set( get(findobj(hh,'type','axes'),'title'), 'string',['Sample ', num2str(s), ' of ', num2str(samples) ])
end

CashFlow=horzcat(-UFCost,SavingPY);
Rate=0.09;
close(hh)
toc

sizeRange=newCap;
[sorttotsaving,sortingtotI] = sort(pbtime,'descend');
% scatter(sizeRange,totsaving)
scatter(sizeRange,sorttotsaving(1:30))
title('Battery Size vs Total Saving')
xlabel('Battery Size / kWh')
ylabel('Total Saving')
hold on

for ss= 1:samples
    Labels1{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels2{ss} = strcat('P: ', num2str(maxPower(ss,1)), ' PB: ', num2str(pbtime(ss)));
    npv(ss,:)=pvvar(CashFlow(ss,:),Rate);
end

labelpoints(sizeRange,totsaving,Labels1,'NE');

figure()
[sortpbtime,sortingI] = sort(pbtime,'ascend');
% scatter( sizeRange, (pbtime))
scatter( sizeRange, sortpbtime(1:30))
title('Payback Period for Battery Based on Size pkWh')
xlabel('Battery Size/ kWh')
ylabel('Payback Time / Years')

labelpoints(sizeRange,pbtime,Labels2,'NE');

[minPBtime, Inpb] = min(pbtime(pbtime>0));
[maxSave, Inms] = max(totsaving);
[maxNpv, Inmn] = max(npv);

disp(['Best PB Time: ', num2str(minPBtime), ' P:' num2str(maxPower(Inpb)),  'C: ' num2str(newCap(Inpb))]);
disp(['Maximum Savings: ', num2str(maxSave), ' P:' num2str(maxPower(Inms)),  'C: ' num2str(newCap(Inms))]);
disp(['Max Net Present Value: ', num2str(maxNpv), ' P:' num2str(maxPower(Inmn)),  'C: ' num2str(newCap(Inmn))]);

% profile off
%
% profile viewer
