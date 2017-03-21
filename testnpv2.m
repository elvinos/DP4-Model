%Sort Size array
[sortSR,sortingSRI] = sort(sizeRange,'ascend');
% creating matching npv array that corresponds with sort size array
allNPV=horzcat(npv1,npv2,npv3);
for anp=1:size(allNPV,2)
    rowzz = allNPV(:,anp);
    sortNPVSR(:,anp)= rowzz(sortingSRI);
end

szallnpv=size(allNPV,2);
npvsizefit=ceil(numel(sortSR)/fitrange);
mSR2=[];
srm3index=[];
mmpv3=[];
srindex=[];
% sortNPV=zeros(szallnpv,npvsizefit)';
sortNPV=[];
sortingNPVI=[];
isr2=[];
x3=[];
srt2npv=[];
srt2Inpv=[];

% sortingNPVI=zeros(szallnpv,npvsizefit);
fitnnPV2=[];
fNn2=[];
maxNPV=[];
maxNPVI=[];
fitrange=4;

for nselec = 1:3
iii=1;
% Find Max values to increase points in this region
colums = sortNPVSR(:,nselec) ;
[srt2npv,srt2Inpv] = sort(colums,'descend');
sortNPV(:,nselec)= srt2npv';
sortingNPVI(:,nselec)= srt2Inpv';
maxNPV(:,nselec)=sortNPV(1:10,nselec);
maxNPVI(:,nselec)=sortingNPVI(1:10,nselec);

for isr = 1:fitrange:(numel(sortSR))
    if any(isr==maxNPVI(:,nselec)) || any(isr==(maxNPVI(:,nselec)+1))|| any(isr==(maxNPVI(:,nselec)+2)) || any(isr==(maxNPVI(:,nselec)+3)) %% Check to catch max values
        for uu = isr:(isr+fitrange-1) %% Run through range to find max values
            if any(uu==maxNPVI(:,nselec)) %% add max valyes to array
                for n= 1:1 %% REPLICATE TO create a closer fit at the max values
                mmpv3(iii,nselec)=sortNPVSR(uu,nselec);
                srindex(iii,nselec) = uu;
                mSR2(iii,nselec)=sortSR(srindex(iii,nselec));
                isr2(iii,nselec)=uu;
                iii= iii +1;
                end
            end
        end

    else

        if u >= numel(sortSR) %% make sure that region does not exceed size of matrix
            u = numel(sortSR);
        else
            u =isr+fitrange-1;
        end
        isr2(iii,nselec)=isr; %% if not a max value find:
        [mmpv3(iii,nselec),srm3index(iii,nselec)]=max(sortNPVSR(isr:u,nselec));% max value in range
        srindex(iii,nselec) = (srm3index(iii,nselec)-1+isr); %% Find corresponding size index
        mSR2(iii,nselec)=sortSR(srindex(iii,nselec)); %% create corresponding size
        iii= iii +1;
   end
end

x=linspace(min(mSR2(:,nselec)),max(mSR2(:,nselec)),size(mSR2,1))';%% Create equally spaced point to imprive fit
x3(:,nselec)=x;
fitnnPV2(:,nselec) = polyfit(mSR2(:,nselec), mmpv3(:,nselec),5); %% Use Five to give best fit
fNn2(:,nselec) = polyval(fitnnPV2(:,nselec),x3(:,nselec));


figure()
scatter(sizeRange, allNPV(:,nselec),20, maxPower,'filled')
caxis([min(maxPower) max(maxPower)]);
colormap(jet);
hold on
plot(mSR2(:,nselec),mmpv3(:,nselec))

plot(x3(:,nselec),fNn2(:,nselec))
end
