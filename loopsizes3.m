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
Rate2=0.09;
Rate1= 0;
Rate3 = 0.15;
close(hh)
toc

sizeRange=newCap;

scatter(sizeRange,totsaving)
title('Battery Size vs Total Saving')
xlabel('Battery Size / kWh')
ylabel('Total Saving')
hold on

for ss= 1:samples
    Labels1{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels2{ss} = strcat('P: ', num2str(maxPower(ss,1)), ' PB: ', num2str(pbtime(ss)));
    npv1(ss,:)=pvvar(CashFlow(ss,:),Rate1);
    npv2(ss,:)=pvvar(CashFlow(ss,:),Rate2);
    npv3(ss,:)=pvvar(CashFlow(ss,:),Rate3);
end

labelpoints(sizeRange,totsaving,Labels1,'NE');

figure()

scatter( sizeRange, (pbtime))

title('Payback Period for Battery Based on Size pkWh')
xlabel('Battery Size/ kWh')
ylabel('Payback Time / Years')

labelpoints(sizeRange,pbtime,Labels2,'NE');

[minPBtime, Inpb] = min(pbtime(pbtime>0));
[maxSave, Inms] = max(totsaving);
[maxNpv1, Inmn1] = max(npv1);
[maxNpv2, Inmn2] = max(npv2);
[maxNpv3, Inmn3] = max(npv3);

disp(['Best PB Time: ', num2str(minPBtime), ' P:' num2str(maxPower(Inpb)),  'C: ' num2str(newCap(Inpb))]);
disp(['Maximum Savings: ', num2str(maxSave), ' P:' num2str(maxPower(Inms)),  'C: ' num2str(newCap(Inms))]);
disp(['Max Net Present Value 0%: ', num2str(maxNpv1), ' P:' num2str(maxPower(Inmn1)),  'C: ' num2str(newCap(Inmn1))]);
disp(['Max Net Present Value 9%: ', num2str(maxNpv2), ' P:' num2str(maxPower(Inmn2)),  'C: ' num2str(newCap(Inmn2))]);
disp(['Max Net Present Value 15%: ', num2str(maxNpv3), ' P:' num2str(maxPower(Inmn3)),  'C: ' num2str(newCap(Inmn3))]);
range=20;
if samples < range
    range=samples;
end

[sorttotsaving,sortingtotI] = sort(totsaving,'descend');
[sortpbtime,sortingI] = sort(pbtime,'ascend');
sizeR2=sizeRange(sortingtotI)';
sizeR3=sizeRange(sortingI)';
maxPower2=maxPower(sortingtotI);
maxPower3=maxPower(sortingI);
figure()
scatter(sizeR2(1:range),sorttotsaving(1:range))
title('Battery Size vs Total Saving (Cond.)')
xlabel('Battery Size / kWh')
ylabel('Total Saving/ £')
hold on


for ss=1:range
 Labels3{ss}=strcat('P: ', num2str(maxPower2(ss,1)));
 Labels4{ss} = strcat('P: ', num2str(maxPower3(ss,1)), ' PB: ', num2str(sortpbtime(ss)));
 Labels5{ss}=strcat('P: ', num2str(npv1(ss,1)));
 Labels6{ss}=strcat('P: ', num2str(npv2(ss,1)));
 Labels7{ss}=strcat('P: ', num2str(npv3(ss,1)));
end
labelpoints(sizeR2(1:range),sorttotsaving(1:range),Labels3,'NE');

figure()
scatter( sizeR3(1:range), sortpbtime(1:range))
title('Payback Period for Battery Based on Size pkWh (Cond.)')
xlabel('Battery Size/ kWh')
ylabel('Payback Time / Years')

labelpoints(sizeR3(1:range), sortpbtime(1:range),Labels4,'NE');

figure()
subplot(2,2,1)
scatter( sizeRange, npv1)
fitnpv1 = polfit(sizeRange, npv1);
title('Net Present Value Based on Battery Size and Power 0% Discount Rate')
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
labelpoints(sizeRange, npv1,Labels5,'NE');
subplot(2,2,2)
scatter( sizeRange, npv2)
fitnpv2 = polyfit(sizeRange, npv2);
title('Net Present Value Based on Battery Size and Power 9% Discount Rate')
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
labelpoints(sizeRange, npv1,Labels6,'NE');
subplot(2,2,3)
scatter( sizeRange, npv3)
fitnpv3 = polyfit(sizeRange, npv3);
title('Net Present Value Based on Battery Size and Power 15% Discount Rate')
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
labelpoints(sizeRange, npv3,Labels5,'NE');
subplot(2,2,4)
plot(fitnpv1)
hold on
plot(fitnpv2)
plot(fitnpv3)
title('Net Present Value Fit Battery Based on Size and Power, Differnt Discount Rates')
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
legend('0%', '9%', '15%');

figure()
scatter3(sizeRange,maxPower,totsaving,'MarkerEdgeColor','k','MarkerFaceColor',[0 .75 .75])
view(-30,10)


% profile off
%
% profile viewer
