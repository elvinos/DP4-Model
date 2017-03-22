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
[livedatause, DataMatmm30, DataMat,sdate] = liveDatasingfunc(fileName); % Run data correction function to create demand profiles 
liveDataSelc= single(livedatause(1:365,:));
liveDataSelc(abs(liveDataSelc)<1e-2) = 0;
rowsDataSelec = size(liveDataSelc,1);
colsDataSelec = size(liveDataSelc,2);
% VERTCAT to save time - need seven to remove errors with weekends
liveDataSelc1= vertcat(liveDataSelc(2:rowsDataSelec,:),liveDataSelc(2,:),liveDataSelc(3:rowsDataSelec,:),liveDataSelc(2:3,:),liveDataSelc(4:rowsDataSelec,:),liveDataSelc(2:4,:),liveDataSelc(5:rowsDataSelec,:),liveDataSelc(2:5,:),liveDataSelc(6:rowsDataSelec,:),liveDataSelc(2:6,:),liveDataSelc(7:rowsDataSelec,:),liveDataSelc(2:7,:),liveDataSelc);
  
for n=1:ceil(runlen/7) % Find Matrix Size
      liveDataSelc = vertcat(liveDataSelc,liveDataSelc1);
end

parfor s = 1:samples % Loop to find results for all batterues
[cumSavyear,Year(s),Saving(s),pbtime(s),SavingPY(s,:),DoDmean(s)] = datalivesingfunc(liveDataSelc,sdate,UFCost(s), newCap(s), maxPower(s),runlen);% battery running function 
totsaving(s)= cumSavyear(1,size(cumSavyear,2));% Create total savings from cumlative savings array
hh.iterate(1); % Parallel
set( get(findobj(hh,'type','axes'),'title'), 'string',['Sample ', num2str(s), ' of ', num2str(samples) ])
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
livedataplotsfunc(livedatause, DataMatmm30, DataMat,sdate) %%% Plots Graph of Data Selected

toc

warning('off','all') %Turn off Warnings for Polyfit
sizeRange=double(newCap);
fittotsaving = polyfit(sizeRange, totsaving,npf);
fitpbtime = polyfit(sizeRange, pbtime,npf);
x2 = linspace(min(sizeRange),max(sizeRange),numel(sizeRange));
ftot = polyval(fittotsaving,x2);
fpb = polyval(fitpbtime,x2);
 
for ss= 1:samples
    Labels1{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels2{ss} = strcat('P: ', num2str(maxPower(ss,1)), ' PB: ', num2str(pbtime(ss)));
    npv1(ss,:)=double(pvvar(CashFlow(ss,:),npvRates.Rate1));
    npv2(ss,:)=double(pvvar(CashFlow(ss,:),npvRates.Rate2));
    npv3(ss,:)=double(pvvar(CashFlow(ss,:),npvRates.Rate3));
    Labels5{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels6{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels7{ss}=strcat('P: ', num2str(maxPower(ss,1)));
    Labels8{ss}=strcat('C: ', num2str(sizeRange(ss,1)));
end 

% fig.SRTS1=figure();
% scatter(sizeRange,totsaving);
% title('Battery Size vs Total Saving')
% xlabel('Battery Size / kWh')
% ylabel('Total Saving')
% hold on
% labelpoints(sizeRange,totsaving,Labels1,'NE');
% plot(x2,ftot);
% %set(gcf,'color','w')
% export_fig SRTS1.eps

% fig.SRPB1=figure();
% scatter( sizeRange, (pbtime));
% title('Payback Period for Battery Based on Size pkWh')
% xlabel('Battery Size/ kWh')
% ylabel('Payback Time / Years')
% hold on
% labelpoints(sizeRange,pbtime,Labels2,'NE');
% plot(x2,fpb);
% %set(gcf,'color','w')
% export_fig SRPB1.eps

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
range=40;
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
% for ss=1:range
%  Labels3{ss}=strcat('P: ', num2str(maxPower2(ss,1)));
%  Labels4{ss} = strcat('P: ', num2str(maxPower3(ss,1)), ' PB: ', num2str(sortpbtime(ss)));
% end
% labelpoints(sizeR2(1:range),sorttotsaving(1:range),Labels3,'NE');
% hold on
% plot(xstot,fstot)


%%%%%%%% PLOTS FOR CONDNSED GRAPHS %%%%%%%%%%%%%%%%%%%%%%%%%%
Colcond = linspecer(3) ;
% Max Plot For Battery Sizes
fig.SRST2=figure();
sp1bs=subplot(2,2,1);
x1=sizeR2(1:range);
y1=sorttotsaving(1:range);
scatter(x1,y1,50, maxPower2(1:range),'filled');
title('Battery Size vs Total Saving (Cond.)')
xlabel('Battery Size / kWh')
ylabel('Total Savings/ £')
colormap(sp1bs,viridis); % <- change color reps...
% ctsc=colorbar;
% set(ctsc, 'Position', [.43 .11 .015 .8150]) %%% For Subplots
% set(ctsc, 'Position', [.91 .11 .015 .8150])
% ylabel(ctsc,'Max Power/ kW')
hold on
grid on
fitrange=2;
polyn=3;
mxmin='descend';
[xfit1,pfit1] = maxFitfunc(x1,y1,fitrange,polyn,mxmin);
fsp1bs=plot(xfit1,pfit1,'Color',Colcond(3,:),'linewidth',1.5);
legend(fsp1bs,'Max Fit Curve')


% export_fig SRST2.eps

% fig.SRPB2=figure();
sp2bs=subplot(2,2,3);

x2=sizeR3(1:range);
y2=sortpbtime(1:range);
scatter(x2,y2,50,maxPower3(1:range),'filled');
title('Battery Size vs Payback Time (Cond.)')
xlabel('Battery Size / kWh')
ylabel('Payback Time/ Years')
colormap(sp2bs,viridis); % <- change color reps...
cpbc=colorbar;
ylabel(cpbc,'Max Power/ kW')
% set(cpbc, 'Position', [.91 .11 .015 .8150])
set(cpbc, 'Position', [.06 .11 .012 .8150]) %%% For Subplots
hold on
grid on
fitrange=2;
polyn=5;
mxmin='ascend';
[xfit2,pfit2] = maxFitfunc(x2,y2,fitrange,polyn,mxmin);
fsb2bs=plot(xfit2,pfit2,'Color',Colcond(3,:),'linewidth',1.5);
legend(fsb2bs,'Max Fit Curve')

% export_fig SRPB2.eps

% MAX POWER TOP FIT PLOT TOTAL SAVINGS
% fig.SRST22=figure();
sp1mp=subplot(2,2,2);
x3=maxPower2(1:range);
y3=sorttotsaving(1:range);
scatter(x3,y3,50, sizeR2(1:range),'filled');
title('Max Power vs Total Saving (Cond.)')
xlabel('Max Power/ kW')
ylabel('Total Savings/ £')
colormap(sp1mp,inferno); % <- change color reps...
% ctsc=colorbar;
% ylabel(ctsc,'Battery Size/ kWh')
% set(ctsc, 'Position', [.91 .11 .015 .8150])
hold on
grid on
fitrange=2;
polyn=3;
mxmin='descend';
[xfit3,pfit3] = maxFitfunc(x3,y3,fitrange,polyn,mxmin);
fsp1mp=plot(xfit3,pfit3,'Color',Colcond(2,:),'linewidth',1.5);
legend(fsp1mp,'Max Fit Curve')

% export_fig SRST22.eps


% MAX POWER TOP FIT PLOT PAYBACK TIME 
% fig.SRPB22=figure();
sp2mp=subplot(2,2,4);
x4=maxPower3(1:range);
y4=sortpbtime(1:range);
scatter(x4,y4,50,sizeR3(1:range),'filled');
title('Max Power vs Payback Time (Cond.)')
xlabel('Max Power/ kW')
ylabel('Payback Time/ Years')
colormap(sp2mp,inferno); % <- change color reps...
cpbc2=colorbar;
ylabel(cpbc2,'Battery Size/ kW')
set(cpbc2, 'Position', [.925 .11 .015 .8150])
hold on
grid on
fitrange=2;
polyn=5;
mxmin='ascend';
[xfit4,pfit4] = maxFitfunc(x4,y4,fitrange,polyn,mxmin);
fsp2mp=plot(xfit4,pfit4,'Color',Colcond(2,:),'linewidth',1.5);
legend(fsp2mp,'Max Fit Curve')

% export_fig SRPB22.eps

export_fig SPA2.eps


% % BATTERY SIZE TOP FIT PLOTS COMPARE
% fig.SRPBTS3=figure();
% yyaxis left
% plot(xfit1,pfit1,'Color',Colcond(2,:),'linewidth',1.5) %% Total Savings
% ylabel('Total Savings/ £')
% hold on 
% yyaxis right
% plot(xfit2,pfit2,'Color',Colcond(3,:),'linewidth',1.5)%% Payback Time
% xlabel('Battery Size / kWh')
% ylabel('Payback Time/ Years')
% title('Comparision of Top Batteries based on Size for Payback Time And Total Savings')
% export_fig SRPBTS3.eps
% 
% % MAX POWER TOP FIT PLOTS COMPARE
% fig.SRPBTS4=figure();
% yyaxis left
% plot(xfit3,pfit3,'Color',Colcond(2,:),'linewidth',1.5) %% Total Savings
% ylabel('Total Savings/ £')
% hold on 
% yyaxis right
% plot(xfit4,pfit4,'Color',Colcond(3,:),'linewidth',1.5)%% Payback Time
% xlabel('Max Power / kW')
% ylabel('Payback Time/ Years')
% title('Comparision of Top Batteries based on Max Power for Payback Time And Total Savings')
% export_fig SRPBTS4.eps

%%%%%% AS SUBPLOTS
% BATTERY SIZE TOP FIT PLOTS COMPARE
fig.SRTSPB5=figure();
BSSP=subplot(1,2,1);
yyaxis left
plot(xfit1,pfit1,'linewidth',2) %% Total Savings
ylabel('Total Savings/ £')
hold on 
grid on
yyaxis right
plot(xfit2,pfit2,'linewidth',2)%% Payback Time
set(BSSP, 'Position', [0.06 0.11 0.4 0.8])
set(BSSP,'ydir','reverse');
xlabel('Battery Size / kWh')
ylabel('Payback Time/ Years')
title({'Comparision of Top Batteries based on', 'Size for Payback Time And Total Savings'})
% MAX POWER TOP FIT PLOTS COMPARE
MPSP = subplot(1,2,2);
yyaxis left
plot(xfit3,pfit3,'linewidth',2) %% Total Savings
ylabel('Total Savings/ £')
hold on 
grid on
yyaxis right
plot(xfit4,pfit4,'linewidth',2)%% Payback Time
set(MPSP,'ydir','reverse');
set(MPSP, 'Position', [0.55 0.11 0.4 0.8])
xlabel('Max Power / kW')
ylabel('Payback Time/ Years')
title({'Comparision of Top Batteries based on', 'Max Power for Payback Time And Total Savings'})
export_fig SRTSPB5.eps

% scatter( sizeR3(1:range), sortpbtime(1:range));
% title('Payback Period for Battery Based on Size pkWh (Cond.)')
% xlabel('Battery Size/ kWh')
% ylabel('Payback Time / Years')
% labelpoints(sizeR3(1:range), sortpbtime(1:range),Labels4,'NE');
% hold on
% plot(xspb,fspb)


%% NPV FIT

%Sort Size array
[sortSR,sortingSRI] = sort(sizeRange,'ascend');
% creating matching npv array that corresponds with sort size array
allNPV=horzcat(npv1,npv2,npv3);

fig.SRNPV1=figure();
srnpvf= [];
mnpvf= [];
xs= [];
fnpv= [];
x3=[];
fpnv=[];
isr2=[];
Colnpv = linspecer(3) ;
for nselec = 1:3
  NPV = allNPV(:,nselec);
  sortNPV2=NPV(sortingSRI);
  iii=1;
  fitrange=4;
  npvsizefit=ceil(numel(sortSR)/fitrange);
  mSR2=zeros(1,50);
  srm3index=zeros(1,50);
  mmpv3=zeros(1,50);
  srindex=zeros(1,50);

  % Find Max values to increase points in this region
  [sortNPV,sortingNPVI] = sort(sortNPV2,'descend');
  maxNPV=sortNPV(1:10);
  maxNPVI=sortingNPVI(1:10);

for isr = 1:fitrange:(numel(sortSR))
    u =isr+fitrange-1;
    if u > numel(sortSR) %% make sure that region does not exceed size of matrix
        u = numel(sortSR);
    end
    if any(isr==maxNPVI)|| any(isr==(maxNPVI+1))|| any(isr==(maxNPVI+2)) || any(isr==(maxNPVI+3)) || any(isr==(maxNPVI+4)) %% Check to catch max values
        for uu = isr:(isr+fitrange-1) %% Run through range to find max values
            if any(uu==maxNPVI) %% add max valyes to array
                for n= 1:3 %% REPLICATE TO create a closer fit at the max values
                mmpv3(iii)=sortNPV2(uu);
                srindex(iii) = uu;
                mSR2(iii)=sortSR(srindex(iii));
                isr2(iii,nselec)=uu;
                iii= iii +1;
                end
            end
        end

    else
    isr2(iii,nselec)=isr; %% if not a max value find:
    [mmpv3(iii),srm3index(iii)]=max(sortNPV2(isr:u));% max value in range
    srindex(iii) = (srm3index(iii)-1+isr); %% Find corresponding size index
    mSR2(iii)=sortSR(srindex(iii)); %% create corresponding size
    iii= iii +1;
    end
end
iu=iii-1;
 if isr2((iu)) ~= numel(sortSR)
    uu = numel(sortSR);
    mmpv3(iu)=sortNPV2(uu);
    srindex(iu) = uu;
    mSR2(iu)=sortSR(srindex(iu));
    isr2(iu)=uu;
 end
    
warning('off','all')
SPNV(nselec)=subplot(2,2,nselec);
x3=linspace(min(mSR2),max(mSR2),numel(mSR2));%% Create equally spaced point to imprive fit
fitnnPV2 = polyfit(mSR2, mmpv3,5); %% Use Five to give best fit
fNn2 = polyval(fitnnPV2,x3);
mmpv3(:,((iii-1):size(mmpv3,2)))=[];
mSR2(:,((iii-1):size(mSR2,2)))=[];
fph=plot(x3,fNn2,'Color',Colnpv(nselec,:),'linewidth',1.5); % Plot of fit line through max points
legend(fph,'Max Fit Curve')
% plot(mSR2,mmpv3) Plot of max points plot line
hold on
scatter( sizeRange, NPV,20, maxPower,'filled')
plot(linspace(0,max(max(sizeRange)),10), linspace(0,0,10),'k--');
title({'Net Present Value Based on Battery Size', ['and Power ', num2str(disrates(nselec)*100),'% Discount Rate']})
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
ylim([min(NPV),max(NPV)*1.1]);
caxis([min(maxPower) max(maxPower)]);
colormap(viridis);


if nselec > 1
    if size(srnpvf,2) <  size(mSR2,2) 
    srnpvf(:,size(mSR2,2)) = 0;
    mnpvf(:,size(mmpv3,2)) = 0;
    x3(:,size(xs,2)) = 0;
    fNn2(:,size(fnpv,2)) = 0;
    else 
    mSR2(size(srnpvf,2)) = 0;
    mmpv3(size(mnpvf,2)) = 0;
    x3(size(xs,2)) = 0;
    fNn2(size(fnpv,2)) = 0;
    end
    srnpvf= vertcat(srnpvf, mSR2);
    mnpvf=vertcat(mnpvf,mmpv3);
    xs=vertcat(xs,x3);
    fnpv=vertcat(fnpv,fNn2);
 else
    srnpvf=mSR2;
    mnpvf=mmpv3;
    xs=x3;
    fnpv=fNn2;
end


end

SPNV(4)=subplot(2,2,4);
for ff = 1:3 %% Plot all fit lines on final subplot
    idxs=[0,0];
    idfn=[0,0];
    xs2=xs(ff,:);
    fnpv3=fnpv(ff,:);
    
    idxs=find(xs2==0,2,'first');
    idfn=find(fnpv3==0,2,'first');
    if numel(idxs) <= 1
        idxs(2) = size(xs,2);
    else
    end
    if numel(idfn) < 1
        idfn(2) = size(fnpv,2);
    else
         idxs=idxs(end);
         xs2(:,idxs:size(xs2,2))=[];
         idfn=idfn(end);
         fnpv3(:,idfn:size(fnpv3,2))=[];
    end
    plot(xs2,fnpv3,'Color',Colnpv(ff,:),'linewidth',2.5)
hold on
end
plot(linspace(0,max(max(xs)),10), linspace(0,0,10),'k--');
title({'Net Present Value Fit Battery Based on Size', 'and Power, Different Discount Rates'})
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
legend('3%', '7%', '12%');
ylim([min(min(fnpv)),max(max(fnpv))*1.1]);
xlim([0,max(sizeRange)]);
%set(gcf,'color','w')
cnpv=colorbar;
caxis([min(maxPower) max(maxPower)]); 
set(cnpv, 'Position', [.93 .11 .015 .8150])
ylabel(cnpv,'Max Power/ kW')

set(SPNV(1), 'Position', [0.06 0.57 0.4 0.36])
set(SPNV(2), 'Position', [0.51 0.57 0.4 0.36])
set(SPNV(3), 'Position', [0.06 0.07 0.4 0.36])
set(SPNV(4), 'Position', [0.51 0.07 0.4 0.36])

export_fig SRNPV1.eps

% fig.SRMPTS1=figure(); % NOT IN USE
% scatter3(sizeRange,maxPower,totsaving,'MarkerEdgeColor','k','MarkerFaceColor',[0 .75 .75])
% view(-30,10)
% xlabel('Battery Size/ kWh')
% ylabel('Max Power/ kW')
% zlabel('Total Saving/ £')
% labelpoints(sizeRange, totsaving,Labels1);
% %set(gcf,'color','w')
% export_fig SRMPTS1.eps

fig.DOD1=figure();
dodsp1=subplot(1,2,1);
scatter(sizeRange,DoDmean,65, maxPower,'filled')
% labelpoints(sizeRange,DoDmean,Labels1);
title('Mean Depth of Discharge vs Battery Size')
xlabel('Battery Size/ kWh')
ylabel('Mean Depth of Discharge / %')
caxis([min(maxPower) max(maxPower)]); 
colormap(dodsp1,viridis); % <- change color reps...
dodcb1=colorbar;
set(dodcb1, 'Position', [.43 .11 .015 .8150])
set(dodsp1, 'Position', [0.06 0.11 0.35 0.8])
grid on
ylabel(dodcb1,'Max Power/ kW')
dodsp2=subplot(1,2,2);
scatter(maxPower,DoDmean,65, sizeRange,'filled')
title('Mean Depth of Discharge vs Max Power')
xlabel('Max Power/ kW')
ylabel('Mean Depth of Discharge / %')
% labelpoints(maxPower,DoDmean,Labels8);
caxis([min(sizeRange) max(sizeRange)]); 
colormap(dodsp2,inferno); % <- change color reps...
dodcb2=colorbar;
grid on
set(dodcb2, 'Position', [.90 .11 .015 .8150])
set(dodsp2, 'Position', [0.54 0.11 0.35 0.8])
ylabel(dodcb2,'Battery Size/ kWh')
export_fig DOD1.eps

% Plot of Colormap For Max Power
fig.SRTS2=figure();
xsr=sizeRange;
ysr=totsaving;
scatter(xsr,ysr,90, maxPower,'filled')
caxis([min(maxPower) max(maxPower)]); 
colormap(viridis); % <- change color reps...
ctsb=colorbar;
grid on 
title('Battery Size vs Total Saving')
xlabel('Battery Size / kWh')
ylabel('Total Saving')
ylabel(ctsb,'Max Power/ kW')
hold on
fitrange=4;
polyn=4;
mxmin='descend';
[xfitsr,pfitsr] = maxFitfunc(xsr,ysr,fitrange,polyn,mxmin);
fsr1=plot(xfitsr,pfitsr,'Color', Colnpv(2,:),'linewidth', 1.5);
legend(fsr1,'Max Fit Curve')
%set(gcf,'color','w')
export_fig SRTS2.eps

fig.MPTS2=figure();
xpm = maxPower;
ypm =totsaving;
scatter(xpm,ypm,80, sizeRange,'filled')
caxis([min(sizeRange) max(sizeRange)]); 
colormap(inferno); % <- change color reps...
ctsb2=colorbar;
grid on
title('Max Power vs Total Savings')
xlabel('Max Power / kW')
ylabel('Total Saving /£')
ylabel(ctsb2,' Battery Size/ kWh')
hold on
fitrange=4;
polyn=4;
mxmin='descend';
[xfitmp,pfitmp] = maxFitfunc(xpm,ypm,fitrange,polyn,mxmin);
fmp1=plot(xfitmp,pfitmp,'Color', Colnpv(3,:),'linewidth', 1.5) ;
legend(fmp1,'Max Fit Curve')
%set(gcf,'color','w')

fig.SRPB2=figure();
xpb=sizeRange;
ypb=pbtime;
scatter(xpb,ypb,80,maxPower,'filled')
caxis([min(maxPower) max(maxPower)]); 
colormap(viridis); % <- change color reps...
ctsb3=colorbar;
grid on
title('Battery Size vs Payback Time')
xlabel('Battery Size / kWh')
ylabel('Payback Time/ Years')
ylabel(ctsb3,'Max Power/ kW')
hold on
fitrange=4;
polyn=4;
mxmin='ascend';
[xfitpb,pfitpb] = maxFitfunc(xpb,ypb,fitrange,polyn,mxmin);
fpb1=plot(xfitpb,pfitpb,'Color', Colnpv(3,:),'linewidth', 1.5);
legend(fpb1,'Max Fit Curve')

%set(gcf,'color','w')
export_fig SRPB2.eps

fig.SRMPTS2=figure();
scatter3(sizeRange,maxPower,totsaving,80, pbtime,'filled')
colormap(magma); % <- change color reps...
cm3=colorbar;
caxis([min(pbtime) max(pbtime)]); 
set(cm3, 'Position', [.948 .11 .015 .8150])
view(-20,20)
title('3D Scatter Plot of Battery Max Power, Size and Total Savings')
xlabel('Battery Size/ kWh')
ylabel('Max Power/ kW')
zlabel('Total Saving/ £')
ylabel(cm3,'Pay Back Time/ Years')
export_fig SRMPTS2.eps

warning('on','all') %Turn on Warnings for Polyfitc

% profile off
%
% profile viewer
