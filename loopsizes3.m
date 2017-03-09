%% Clear And Close
clc
clear all
close all force
% profile clear
% profile on

%% Powerpack Calculation
UFCost = 86330;
INCost = 0;
mainCost = 0;
s= 1;
minSize=100;
maxSize=350;
step=25;
samples=(maxSize-minSize)/step;
maxPower= 100;
ppkwh=500;
runlen=25;
ufcost=zeros(1,samples);
sizeRange=zeros(1,samples);
pbtime=zeros(1,samples);
Year=zeros(1,samples);
Saving=zeros(1,samples);
totsaving=zeros(1,samples);
hh = waitbar(0,'Please wait...');

for newCap = minSize:step:maxSize
UFCost = newCap*ppkwh;
sizeRange(s)=newCap;
[cumSavyear,Year(s),Saving(s),pbtime(s)] = datalivefunc(UFCost, newCap, maxPower,runlen);
totsaving(s)= cumSavyear(1,size(cumSavyear,2));
waitbar(s/(samples+1));
set( get(findobj(hh,'type','axes'),'title'), 'string',['Sample ', num2str(s), ' of ', num2str(samples+1) ])
s= s+1;
end
close(hh)

plot(sizeRange,totsaving)
title('Battery Size vs Total Saving')
xlabel('Battery Size / kWh')
ylabel('Total Saving')

figure()
plot( sizeRange, (pbtime))
title('Payback Period for Battery Based on Size pkWh')
xlabel('Cost of Battery Based on Size/ kWh')
ylabel('Payback Time / Years')

% profile off
%
% profile viewer
