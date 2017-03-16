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

tic
[livedatause,DataMatmm30,DataMat,sdate] = liveDatafunc(fileName);
liveDataSelc= livedatause(1:365,:);
liveDataSelc(abs(liveDataSelc)<1e-2) = 0;
rowsDataSelec = size(liveDataSelc,1);
colsDataSelec = size(liveDataSelc,2);
liveDataSelc1= vertcat(liveDataSelc(2:rowsDataSelec,:),liveDataSelc(2,:),liveDataSelc(3:rowsDataSelec,:),liveDataSelc(2:3,:),liveDataSelc(4:rowsDataSelec,:),liveDataSelc(2:4,:),liveDataSelc(5:rowsDataSelec,:),liveDataSelc(2:5,:),liveDataSelc(6:rowsDataSelec,:),liveDataSelc(2:6,:),liveDataSelc(7:rowsDataSelec,:),liveDataSelc(2:7,:),liveDataSelc);
  for n=1:ceil(runlen/7)
      liveDataSelc = vertcat(liveDataSelc,liveDataSelc1);
  end

parfor s = 1:samples
[cumSavyear,Year(s),Saving(s),pbtime(s),SavingPY(s,:),DoDmean(s)] = datalivecondfunc(liveDataSelc,sdate,UFCost(s), newCap(s), maxPower(s),runlen);
totsaving(s)= cumSavyear(1,size(cumSavyear,2));
hh.iterate(1); % Parallel
set( get(findobj(hh,'type','axes'),'title'), 'string',['Sample ', num2str(s), ' of ', num2str(samples) ])
end
totsaving=totsaving';
pbtime=pbtime';
CashFlow=horzcat(-UFCost,SavingPY);
Rate1= 0.03;
Rate2=0.07;
Rate3 = 0.12;
npf=3;
close(hh)

set(0,'DefaultFigureWindowStyle','docked')
livedataplotsfunc(livedatause, DataMatmm30, DataMat,sdate) %%% Plots Graph of Data Selected

toc

warning('off','all') %Turn off Warnings for Polyfit
sizeRange=newCap;
fittotsaving = polyfit(sizeRange, totsaving,npf);
fitpbtime = polyfit(sizeRange, pbtime,npf);
x2 = linspace(min(sizeRange),max(sizeRange),numel(sizeRange));
ftot = polyval(fittotsaving,x2);
fpb = polyval(fitpbtime,x2);

for ss= 1:samples
    Labels1{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels2{ss} = strcat('P: ', num2str(maxPower(ss,1)), ' PB: ', num2str(pbtime(ss)));
    npv1(ss,:)=pvvar(CashFlow(ss,:),Rate1);
    npv2(ss,:)=pvvar(CashFlow(ss,:),Rate2);
    npv3(ss,:)=pvvar(CashFlow(ss,:),Rate3);
    Labels5{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels6{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels7{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels8{ss}=strcat('C: ', num2str(sizeRange(ss,1)));
end 

scatter(sizeRange,totsaving)
title('Battery Size vs Total Saving')
xlabel('Battery Size / kWh')
ylabel('Total Saving')
hold on
labelpoints(sizeRange,totsaving,Labels1,'NE');
plot(x2,ftot);

figure()

scatter( sizeRange, (pbtime))
title('Payback Period for Battery Based on Size pkWh')
xlabel('Battery Size/ kWh')
ylabel('Payback Time / Years')
hold on
labelpoints(sizeRange,pbtime,Labels2,'NE');
plot(x2,fpb);

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
fitsorttotsaving = polyfit(sizeR2(1:range),sorttotsaving(1:range)', npf);
fittotsortpbtime= polyfit(sizeR3(1:range), sortpbtime(1:range)', npf);
xstot = linspace(min(sizeR2(1:range)),max(sizeR2(1:range)),numel(sizeR2(1:range)));
xspb = linspace(min(sizeR3(1:range)),max(sizeR3(1:range)),numel(sizeR3(1:range)));
fstot = polyval(fitsorttotsaving,xstot);
fspb = polyval(fittotsortpbtime,xspb);

figure()
scatter(sizeR2(1:range),sorttotsaving(1:range))
title('Battery Size vs Total Saving (Cond.)')
xlabel('Battery Size / kWh')
ylabel('Total Saving/ £')
hold on
for ss=1:range
 Labels3{ss}=strcat('P: ', num2str(maxPower2(ss,1)));
 Labels4{ss} = strcat('P: ', num2str(maxPower3(ss,1)), ' PB: ', num2str(sortpbtime(ss)));
end
labelpoints(sizeR2(1:range),sorttotsaving(1:range),Labels3,'NE');
hold on
plot(xstot,fstot)


figure()
scatter( sizeR3(1:range), sortpbtime(1:range))
title('Payback Period for Battery Based on Size pkWh (Cond.)')
xlabel('Battery Size/ kWh')
ylabel('Payback Time / Years')
labelpoints(sizeR3(1:range), sortpbtime(1:range),Labels4,'NE');
hold on
plot(xspb,fspb)

fitnpv1 = polyfit(sizeRange, npv1,npf);
fitnpv2 = polyfit(sizeRange, npv2,npf);
fitnpv3 = polyfit(sizeRange, npv3,npf);
f1 = polyval(fitnpv1,x2);
f2 = polyval(fitnpv2,x2);
f3 = polyval(fitnpv3,x2);

figure()
subplot(2,2,1)
scatter( sizeRange, npv1)
hold on
plot(x2,f1)
title({'Net Present Value Based on Battery Size', 'and Power 3% Discount Rate'})
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
labelpoints(sizeRange, npv1,Labels5,'NE');

subplot(2,2,2)
scatter( sizeRange, npv2)
hold on
plot(x2,f2)
title({'Net Present Value Based on Battery Size', 'and Power 7% Discount Rate'})
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
labelpoints(sizeRange, npv2,Labels6,'NE');

subplot(2,2,3)
scatter( sizeRange, npv3)
hold on
plot(x2,f3)
title({'Net Present Value Based on Battery Size', 'and Power 12% Discount Rate'})
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
labelpoints(sizeRange, npv3,Labels7,'NE');

subplot(2,2,4)
plot(x2,f1)
hold on
plot(x2,f2)
plot(x2,f3)
title({'Net Present Value Fit Battery Based on Size', 'and Power, Differnt Discount Rates'})
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
legend('3%', '7%', '12%');
warning('on','all') %Turn on Warnings for Polyfit

figure()
scatter3(sizeRange,maxPower,totsaving,'MarkerEdgeColor','k','MarkerFaceColor',[0 .75 .75])
view(-30,10)
xlabel('Battery Size/ kWh')
ylabel('Max Power/ kW')
zlabel('Total Saving/ £')
labelpoints(sizeRange, totsaving,Labels1);

figure()
subplot(1,2,1)
scatter(sizeRange,DoDmean)
labelpoints(sizeRange,DoDmean,Labels1);
xlabel('Battery Size/ kWh')
ylabel('Mean Depth of Discharge / %')
subplot(1,2,2)
scatter(maxPower,DoDmean)
xlabel('Max Power/ kW')
ylabel('Mean Depth of Discharge / %')
labelpoints(maxPower,DoDmean,Labels8);


% profile off
%
% profile viewer
