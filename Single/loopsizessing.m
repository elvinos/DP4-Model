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

fig.SRST2=figure();
scatter(sizeR2(1:range),sorttotsaving(1:range));
title('Battery Size vs Total Saving (Cond.)')
xlabel('Battery Size / kWh')
ylabel('Total Saving/ �')
%set(gcf,'color','w')
hold on
for ss=1:range
 Labels3{ss}=strcat('P: ', num2str(maxPower2(ss,1)));
 Labels4{ss} = strcat('P: ', num2str(maxPower3(ss,1)), ' PB: ', num2str(sortpbtime(ss)));
end
labelpoints(sizeR2(1:range),sorttotsaving(1:range),Labels3,'NE');
hold on
plot(xstot,fstot)
export_fig SRST2.eps


fig.SRPB2=figure();
scatter( sizeR3(1:range), sortpbtime(1:range));
title('Payback Period for Battery Based on Size pkWh (Cond.)')
xlabel('Battery Size/ kWh')
ylabel('Payback Time / Years')
%set(gcf,'color','w')
labelpoints(sizeR3(1:range), sortpbtime(1:range),Labels4,'NE');
hold on
plot(xspb,fspb)
export_fig SRPB2.eps

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
 if isr2((iii-1),nselec) ~= numel(sortSR)
    uu = numel(sortSR);
    mmpv3(iii)=sortNPV2(uu);
    srindex(iii) = uu;
    mSR2(iii)=sortSR(srindex(iii));
    isr2(iii,nselec)=uu;
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
ylabel('Net Present Value / �')
ylim([min(NPV),max(NPV)*1.1]);
caxis([min(maxPower) max(maxPower)]);
colormap(jet);


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

SBNV(4)=subplot(2,2,4);
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
ylabel('Net Present Value / �')
legend('3%', '7%', '12%');
ylim([min(min(fnpv)),max(max(fnpv))*1.1]);
xlim([0,max(sizeRange)]);
%set(gcf,'color','w')
cnpv=colorbar;
caxis([min(maxPower) max(maxPower)]); 
set(cnpv, 'Position', [.93 .11 .015 .8150])
ylabel(cnpv,'Max Power/ kW')

export_fig SRNPV1.eps

% fig.SRMPTS1=figure(); % NOT IN USE
% scatter3(sizeRange,maxPower,totsaving,'MarkerEdgeColor','k','MarkerFaceColor',[0 .75 .75])
% view(-30,10)
% xlabel('Battery Size/ kWh')
% ylabel('Max Power/ kW')
% zlabel('Total Saving/ �')
% labelpoints(sizeRange, totsaving,Labels1);
% %set(gcf,'color','w')
% export_fig SRMPTS1.eps

fig.DOD1=figure();
subplot(1,2,1)
scatter(sizeRange,DoDmean,90, maxPower,'filled')
set(gcf,'color','w')
% labelpoints(sizeRange,DoDmean,Labels1);
xlabel('Battery Size/ kWh')
ylabel('Mean Depth of Discharge / %')
caxis([min(maxPower) max(maxPower)]); 
colormap(jet); % <- change color reps...
colorbar;
subplot(1,2,2)
scatter(maxPower,DoDmean,90, sizeRange,'filled')
xlabel('Max Power/ kW')
ylabel('Mean Depth of Discharge / %')
% labelpoints(maxPower,DoDmean,Labels8);
caxis([min(sizeRange) max(sizeRange)]); 
colormap(jet); % <- change color reps...
colorbar;
export_fig DOD1.eps

% Plot of Colormap For Max Power
fig.SRTS2=figure();
scatter(sizeRange,totsaving,90, maxPower,'filled')
caxis([min(maxPower) max(maxPower)]); 
colormap(jet); % <- change color reps...
colorbar;
title('Battery Size vs Total Saving')
xlabel('Battery Size / kWh')
ylabel('Total Saving')
ylabel(colorbar,'Max Power/ kW')
%set(gcf,'color','w')
export_fig SRTS2.eps

fig.MPTS2=figure();
scatter(maxPower,totsaving,90, sizeRange,'filled')
caxis([min(sizeRange) max(sizeRange)]); 
colormap(jet); % <- change color reps...
colorbar;
title('Max Power vs Total Savings')
xlabel('Max Power / kW')
ylabel('Total Saving /�')
ylabel(colorbar,' Battery Size/ kWh')
%set(gcf,'color','w')

fig.SRPB2=figure();
scatter(sizeRange,pbtime,90,maxPower,'filled')
caxis([min(maxPower) max(maxPower)]); 
colormap(jet); % <- change color reps...
colorbar;
title('Battery Size vs Payback Time')
xlabel('Battery Size / kWh')
ylabel('Payback Time/ Years')
ylabel(colorbar,'Max Power/ kW')
%set(gcf,'color','w')
export_fig SRPB2.eps

fig.SRMPTS2=figure();
scatter3(sizeRange,maxPower,totsaving,90, pbtime,'filled')
colormap(jet); % <- change color reps...
cm3=colorbar;
caxis([min(pbtime) max(pbtime)]); 
set(cm3, 'Position', [.948 .11 .015 .8150])
view(-20,20)
title('3D Scatter Plot of Battery Max Power, Size and Total Savings')
xlabel('Battery Size/ kWh')
ylabel('Max Power/ kW')
zlabel('Total Saving/ �')
ylabel(cm3,'Pay Back Time/ Years')
export_fig SRMPTS2.eps

warning('on','all') %Turn on Warnings for Polyfit
%set(gcf,'color','w')


% % export_fig ( ../Img/.eps);

% profile off
%
% profile viewer
