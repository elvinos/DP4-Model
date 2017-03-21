% % ax(1)=subplot(4,1,1);
% % imagesc(magic(5),[1 64])
% % ax(2)=subplot(4,1,2);
% % imagesc(magic(6),[1 64])
% % ax(3)=subplot(4,1,3);
% % imagesc(magic(7),[1 64])
% % ax(4)=subplot(4,1,4);
% % imagesc(magic(8),[1 64])
% % h=colorbar;
% % set(h, 'Position', [.8314 .11 .0581 .8150])
% % for i=1:4
% %       pos=get(ax(i), 'Position');
% %       set(ax(i), 'Position', [pos(1) pos(2) 0.85*pos(3) pos(4)]);
% % end
% 
% SRNPV1=figure();
% SBNV(1)=subplot(2,2,1);
% scatter( sizeRange, npv1,90, maxPower,'filled')
% caxis([min(maxPower) max(maxPower)]); 
% colormap(jet);
% %set(gcf,'color','w')
% hold on
% plot(x2,f1)
% title({'Net Present Value Based on Battery Size', 'and Power 3% Discount Rate'})
% xlabel('Battery Size/ kWh')
% ylabel('Net Present Value / �')
% % labelpoints(sizeRange, npv1,Labels5,'NE');
% 
% SBNV(2)=subplot(2,2,2);
% scatter( sizeRange, npv2,90, maxPower,'filled')
% caxis([min(maxPower) max(maxPower)]); 
% colormap(jet);
% hold on
% plot(x2,f2)
% title({'Net Present Value Based on Battery Size', 'and Power 7% Discount Rate'})
% xlabel('Battery Size/ kWh')
% ylabel('Net Present Value / �')
% labelpoints(sizeRange, npv2,Labels6,'NE');
% 
% SBNV(4)=subplot(2,2,3);
% scatter( sizeRange, npv3,90, maxPower,'filled')
% caxis([min(maxPower) max(maxPower)]); 
% colormap(jet);
% hold on
% plot(x2,f3)
% title({'Net Present Value Based on Battery Size', 'and Power 12% Discount Rate'})
% xlabel('Battery Size/ kWh')
% ylabel('Net Present Value / �')
% labelpoints(sizeRange, npv3,Labels7,'NE');
% 
% SBNV(4)=subplot(2,2,4);
% plot(x2,f1)
% hold on
% plot(x2,f2)
% plot(x2,f3)
% title({'Net Present Value Fit Battery Based on Size', 'and Power, Differnt Discount Rates'})
% xlabel('Battery Size/ kWh')
% ylabel('Net Present Value / �')
% legend('3%', '7%', '12%');
% %set(gcf,'color','w')
% warning('on','all') %Turn on Warnings for Polyfit
% cnpv=colorbar;
% set(cnpv, 'Position', [.8314 .11 .0581 .8150])
% % for i=1:4
% %       pos=get(SBNV(i), 'Position');
% %       set(SBNV(i), 'Position', [pos(1) pos(2) 0.85*pos(3) pos(4)]);
% % end

% set(fig.SRMPTS2,'TickLabelInterpreter', 'latex')
% export_fig test2.eps
% get(fieldnames(fig.SRTS1))

% text=char(fieldnames(fig.SRTS1));
% name=sprintf('%d.eps', text);
% export_fig (fig.SRTS1, name);

% export_fig ../Img/test.eps
% export_fig ../Img/fig.png;
% export_fig('C:/Users/Me/Documents/figures/myfig', '-pdf', '-png');

% for field = fieldnames(fig)' %note the ' (transpose) is important!
%   currentfield = field{1};
%   export_fig (fig.(currentfield) ../Img/ .eps);
%    export_fig (sprintf('..%d.eps', fig.(currentfield)))
%   disp(currentfield)

% fitnpv1 = polyfit(sizeRange, npv1,npf);
% fitnpv2 = polyfit(sizeRange, npv2,npf);
% fitnpv3 = polyfit(sizeRange, npv3,npf);
% f1 = polyval(fitnpv1,x2);
% f2 = polyval(fitnpv2,x2);
% f3 = polyval(fitnpv3,x2);

% f=fit(sizeRange, npv1,'poly5');
% c = coeffvalues(f);
% cd = polyder(c);
% roots(cd)

% fo = fitoptions('Method','NonlinearLeastSquares',...
%                'Lower',[0,0],...
%                'Upper',[Inf,max(sizeRange)],...
%                'StartPoint',[1 1]);
% ft = fittype('a*(x-b)^n','problem','n','options',fo);
% 
% [curve3,gof3] = fit(sizeRange,npv1,ft,'problem',3);
% 
% figure()
% hold on
% plot(curve3,'c')
% legend('Data','n=2','n=3')
% hold off

% fig.SRNPV1=figure();
% SBNV(1)=subplot(2,2,1);
% scatter( sizeRange, npv1,20, maxPower,'filled')
% caxis([min(maxPower) max(maxPower)]); 
% colormap(jet);
% %set(gcf,'color','w')
% hold on
% plot(x2,f1)
% title({'Net Present Value Based on Battery Size', 'and Power 3% Discount Rate'})
% xlabel('Battery Size/ kWh')
% ylabel('Net Present Value / �')
% % labelpoints(sizeRange, npv1,Labels5,'NE');
% 

%% Single 
% 
%Sort Size array 
[sortSR,sortingSRI] = sort(sizeRange,'ascend');
% creating matching npv array that corresponds with sort size array
allNPV=horzcat(npv1,npv2,npv3);

sortNPV2=npv2(sortingSRI);


iii=1;
fitrange=4;
npvsizefit=ceil(numel(sortSR)/fitrange);
mSR2=zeros(1,npvsizefit);
srm3index=zeros(1,npvsizefit);
mmpv3=zeros(1,npvsizefit);
srindex=zeros(1,npvsizefit);

% Find Max values to increase points in this region
[sortNPV,sortingNPVI] = sort(sortNPV2,'descend');
maxNPV=sortNPV(1:10);
maxNPVI=sortingNPVI(1:10);

for isr = 1:fitrange:(numel(sortSR)-1)
    u =isr+fitrange-1;
    if u >= numel(sortSR) %% make sure that region does not exceed size of matrix
        u = numel(sortSR);
    end
    if any(isr==maxNPVI)|| any(isr==(maxNPVI+1))|| any(isr==(maxNPVI+2)) || any(isr==(maxNPVI+3)) %% Check to catch max values
        for uu = isr:(isr+fitrange-1) %% Run through range to find max values
            if any(uu==maxNPVI) %% add max valyes to array
                for n= 1:1 %% REPLICATE TO create a closer fit at the max values 
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
    [mmpv3(iii),srm3index(iii)]=max(sortNPV2(isr:u));% max value in range 
    srindex(iii) = (srm3index(iii)-1+isr); %% Find corresponding size index
    mSR2(iii)=sortSR(srindex(iii)); %% create corresponding size
    iii= iii +1;
    end
end 

figure()
scatter( sizeRange, npv2,20, maxPower,'filled')
caxis([min(maxPower) max(maxPower)]); 
colormap(jet);
hold on

x3=linspace(min(mSR2),max(mSR2),numel(mSR2));%% Create equally spaced point to imprive fit
fitnnPV2 = polyfit(mSR2, mmpv3,5); %% Use Five to give best fit
fNn2 = polyval(fitnnPV2,x3);

plot(mSR2,mmpv3)
plot(x3,fNn2)

%% All


% %Sort Size array 
% [sortSR,sortingSRI] = sort(sizeRange,'ascend');
% % creating matching npv array that corresponds with sort size array
% allNPV=horzcat(npv1,npv2,npv3);
% for anp=1:size(allNPV,2)
%     rowzz = allNPV(:,anp);
%     sortNPVSR(:,anp)= rowzz(sortingSRI);
% end
% 
% szallnpv=size(allNPV,2);
% npvsizefit=ceil(numel(sortSR)/fitrange);
% mSR2=[];
% srm3index=[];
% mmpv3=[];
% srindex=[];
% % sortNPV=zeros(szallnpv,npvsizefit)';
% sortNPV=[];
% sortingNPVI=[];
% isr2=[];
% x3=[];
% srt2npv=[];
% srt2Inpv=[];
% 
% % sortingNPVI=zeros(szallnpv,npvsizefit);
% fitnnPV2=[];
% fNn2=[];
% maxNPV=[];
% maxNPVI=[];
% fitrange=4;
% 
% for nselec = 1:3
% iii=1;
% % Find Max values to increase points in this region
% rowzzz = allNPV(:,nselec);
% [srt2npv,srt2Inpv] = sort(rowzzz,'descend');
% sortNPV(:,nselec)=srt2npv';
% sortingNPVI(:,nselec)=srt2Inpv';
% maxNPV(:,nselec)=sortNPV(1:10,nselec);
% maxNPVI(:,nselec)=sortingNPVI(1:10,nselec);
% 
% for isr = 1:fitrange:(numel(sortSR))
%     if any(isr==maxNPVI(:,nselec)) || any(isr==(maxNPVI(:,nselec)+1))|| any(isr==(maxNPVI(:,nselec)+2)) || any(isr==(maxNPVI(:,nselec)+3)) %% Check to catch max values
%         for uu = isr:(isr+fitrange-1) %% Run through range to find max values
%             if any(uu==maxNPVI(:,nselec)) %% add max valyes to array
%                 for n= 1:1 %% REPLICATE TO create a closer fit at the max values 
%                 mmpv3(iii,nselec)=sortNPVSR(uu,nselec);
%                 srindex(iii,nselec) = uu;
%                 mSR2(iii,nselec)=sortSR(srindex(iii,nselec));
%                 isr2(iii,nselec)=uu;
%                 iii= iii +1;
%                 end
%             end
%         end
%     
%     else
%     
%         if u >= numel(sortSR) %% make sure that region does not exceed size of matrix
%             u = numel(sortSR);
%         else
%             u =isr+fitrange-1;
%         end
%         isr2(iii,nselec)=isr; %% if not a max value find:
%         [mmpv3(iii,nselec),srm3index(iii,nselec)]=max(sortNPVSR(isr:u,nselec));% max value in range 
%         srindex(iii,nselec) = (srm3index(iii,nselec)-1+isr); %% Find corresponding size index
%         mSR2(iii,nselec)=sortSR(srindex(iii,nselec)); %% create corresponding size
%         iii= iii +1;
%    end
% end 
% 
% x=linspace(min(mSR2(:,nselec)),max(mSR2(:,nselec)),size(mSR2,1))';%% Create equally spaced point to imprive fit
% x3(:,nselec)=x;
% fitnnPV2(:,nselec) = polyfit(mSR2(:,nselec), mmpv3(:,nselec),5); %% Use Five to give best fit
% fNn2(:,nselec) = polyval(fitnnPV2(:,nselec),x3(:,nselec));
% 
% 
% figure()
% scatter(sizeRange, allNPV(:,nselec),20, maxPower,'filled')
% caxis([min(maxPower) max(maxPower)]); 
% colormap(jet);
% hold on
% plot(mSR2(:,nselec),mmpv3(:,nselec))
% 
% plot(x3(:,nselec),fNn2(:,nselec))
% end

% ii=1;
% for i=1:size(npv2,1)
%     if npv2(i) > 0
%         nPV21(ii)=npv2(i);
%         sR2(ii)=sizeRange(i);
%         ii=ii+1;
%     end
% end
% mn=min(sR2);
% mx=max(sR2);
% x3=linspace(mn,mx,size(sR2,2));
% 
% fitnPV2 = polyfit(sR2, nPV21,npf);
% fN2 = polyval(fitnPV2,x3);
% figure()
% scatter( sizeRange, npv2,20, maxPower,'filled')
% caxis([min(maxPower) max(maxPower)]); 
% colormap(jet);
% hold on
% % plot(x2,f2)
% plot(x3,fN2)
% title({'Net Present Value Based on Battery Size', 'and Power 7% Discount Rate'})
% xlabel('Battery Size/ kWh')
% ylabel('Net Present Value / �')

% labelpoints(sizeRange, npv2,Labels6,'NE');
% 
% SBNV(4)=subplot(2,2,3);
% scatter( sizeRange, npv3,20, maxPower,'filled')
% caxis([min(maxPower) max(maxPower)]); 
% colormap(jet);
% hold on
% plot(x2,f3)
% title({'Net Present Value Based on Battery Size', 'and Power 12% Discount Rate'})
% xlabel('Battery Size/ kWh')
% ylabel('Net Present Value / �')
% % labelpoints(sizeRange, npv3,Labels7,'NE');
% 
% SBNV(4)=subplot(2,2,4);
% plot(x2,f1)
% hold on
% plot(x2,f2)
% plot(x2,f3)
% title({'Net Present Value Fit Battery Based on Size', 'and Power, Differnt Discount Rates'})
% xlabel('Battery Size/ kWh')
% ylabel('Net Present Value / �')
% legend('3%', '7%', '12%');
% %set(gcf,'color','w')
% warning('on','all') %Turn on Warnings for Polyfit
% cnpv=colorbar;
% caxis([min(maxPower) max(maxPower)]); 
% set(cnpv, 'Position', [.93 .11 .02 .8150])
% end