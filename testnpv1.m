%% Single
% MAKE SURE YOU RUN LOOPS SIZES BEFORE RUNNING 
%Sort Size array
[sortSR,sortingSRI] = sort(sizeRange,'ascend');
% creating matching npv array that corresponds with sort size array
allNPV=horzcat(npv1,npv2,npv3);
disrate=[0.03,0.07,0.12];
fig.SRNPV1=figure();

% srnpvf= zeros(50,1);
% mnpvf= zeros(50,1);
% xs= zeros(50,3);
% fnpv= zeros(50,3);
srnpvf= [];
mnpvf= [];
xs= [];
fnpv= [];
x3=[];
fpnv=[];

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

for isr = 1:fitrange:(numel(sortSR)-1)
    u =isr+fitrange-1;
%     if u > numel(sortSR) %% make sure that region does not exceed size of matrix
%         u = numel(sortSR);
%     end
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
warning('off','all')
SPNV(nselec)=subplot(2,2,nselec);
scatter( sizeRange, NPV,20, maxPower,'filled')
title({'Net Present Value Based on Battery Size', ['and Power ', num2str(disrate(nselec)*100),'% Discount Rate']})
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
caxis([min(maxPower) max(maxPower)]);
colormap(jet);
hold on
x3=linspace(min(mSR2),max(mSR2),numel(mSR2));%% Create equally spaced point to imprive fit
fitnnPV2 = polyfit(mSR2, mmpv3,5); %% Use Five to give best fit
fNn2 = polyval(fitnnPV2,x3);
mmpv3(:,((iii-1):size(mmpv3,2)))=[];
mSR2(:,((iii-1):size(mSR2,2)))=[];
% plot(mSR2,mmpv3) Plot of max points plot line
plot(x3,fNn2) % Plot of fit line through max points

if nselec > 1
    mSR2(size(srnpvf,2)) = 0;
    mmpv3(size(mnpvf,2)) = 0;
    x3(size(xs,2)) = 0;
    fNn2(size(fnpv,2)) = 0;
else
    
end
srnpvf= vertcat(srnpvf, mSR2);
mnpvf=vertcat(mnpvf,mmpv3);
xs=vertcat(xs,x3);
fnpv=vertcat(fnpv,fNn2);

warning('on','all')
% mSR2T= mSR2';
% mmpv3T=mmpv3';
% x3T=x3';
% fNn2T=fNn2';
end

SBNV(4)=subplot(2,2,4);
for ff = 1:3
    idxs(2)=0;
    idfn(2)=0;
    xs2=xs(ff,:);
    fnpv2=fnpv(ff,:);
    
    idxs=find(xs2==0,2,'first');
    idfn=find(fnpv2==0,2,'first');
    if numel(idxs) <= 1
%         idxs(2) = size(xs,2);
    else
        idxs=idxs(end);
        xs2(:,idxs:size(xs2,2))=[];
    end
     if numel(idfn) < 1
%         idfn(2) = size(fnpv,2);
     else
         idfn=idfn(end);
         fnpv2(:,idfn:size(fnpv2,2))=[];
    end
    plot(xs2,fnpv2)
hold on
end
title({'Net Present Value Fit Battery Based on Size', 'and Power, Differnt Discount Rates'})
xlabel('Battery Size/ kWh')
ylabel('Net Present Value / £')
legend('3%', '7%', '12%');
%set(gcf,'color','w')
warning('on','all') %Turn on Warnings for Polyfit
cnpv=colorbar;
caxis([min(maxPower) max(maxPower)]); 
set(cnpv, 'Position', [.93 .11 .015 .8150])
ylabel(cnpv,'Max Power/ kW')
