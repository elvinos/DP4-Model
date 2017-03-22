function [x3,fNn2] = maxFitfunc(x,y,fitrange,polyn,mxmin)
 
% Single 
% 
% Sort Size array 
% szR2f=x;
% srttot2f=y;

[sortSR,sortingSRI] = sort(x,'ascend');
sortNPV2=y(sortingSRI); % creating matching npv array that corresponds with sort size array


iii=1;
% fitrange=2;
npvsizefit=ceil(numel(sortSR)/fitrange);
mSR2=zeros(1,npvsizefit);
srm3index=zeros(1,npvsizefit);
mmpv3=zeros(1,npvsizefit);
srindex=zeros(1,npvsizefit);


% Find Max values to increase points in this region
[sortNPV,sortingNPVI] = sort(sortNPV2,mxmin);
maxNPV=sortNPV(1:10);
maxNPVI=sortingNPVI(1:10);

mmpv3(iii)=sortNPV2(1);
srindex(iii) = 1;
mSR2(iii)=sortSR(srindex(iii));
isr2(iii)=1;
iii= iii +1;

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
                isr2(iii)=uu;
                iii= iii +1;
                end
            end
        end

    else
    isr2(iii)=isr; %% if not a max value find:
    if isequal(mxmin,'descend')
    [mmpv3(iii),srm3index(iii)]=max(sortNPV2(isr:u));% max value in range
    else
    [mmpv3(iii),srm3index(iii)]=min(sortNPV2(isr:u));% max value in range
    end
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

% figure()
% scatter(szR2f,srttot2f);
% title('Battery Size vs Total Saving (Cond.)')
% xlabel('Battery Size / kWh')
% ylabel('Total Saving/ £')
% set(gcf,'color','w')
% hold on

x3=linspace(min(mSR2),max(mSR2),numel(mSR2));%% Create equally spaced point to improve fit
fitnnPV2 = polyfit(mSR2, mmpv3,polyn); %% Use Five to give best fit
fNn2 = polyval(fitnnPV2,x3);

% plot(mSR2,mmpv3)
% plot(x3,fNn2)

end