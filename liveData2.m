%% Clear And Close
clc
clear all
close all
 
%% Variables
plsct = 1; %Select the number of Plots to Create
rnfit = 1.5; % Select the fit of Different kWh Samples
%% Create Data
% NOTE: USE = kWh
%       DEM = kW

fileName = 'JRBLab1.csv';

[Data]=senateEDD1(fileName);
rowsData= size(Data,1);
colsData= size(Data,2);
DataMat = cell2mat(Data(2:rowsData,4:colsData));
sdate=string(Data(2,1));
rowsDataMat = size(DataMat,1);
colsDataMat = size(DataMat,2);

Meandat = mean(mean(DataMat/30));
Maxdat = max(max(DataMat/30));
MnMx = [Meandat,Maxdat];
rnfit= mean(MnMx);
for n=1:rowsDataMat

    for c = 1:48
        cc= c/2;
        TimeHH(:,c)= cc;
        cm = (c)*30;
        if c == 1 %Create a flat gradient for the first 30 mins
            grad(n,c) = 0;
            const(n,c) = DataMat(n,c)-grad(n,c)*cm;
            midpoint(n,c) = (DataMat(n,c));
            point = [(DataMat(n,c)),(DataMat(n,c)),(DataMat(n,c))];
        else %Use Gradient between points to create Minute by minute useage
            grad(n,c)=((DataMat(n,c)-DataMat(n,c-1))/(30));
            const(n,c)=DataMat(n,c) - grad(n,c)*cm;
            midpoint(n,c) = (DataMat(n,c)+DataMat(n,c-1))/2;
            point = [DataMat(n,c-1),midpoint(n,c),(DataMat(n,c))];
        end
        
        
        for s=1:3
            ss=(s-1)*10+1;
            se=s*10;
            if point(s) >0
            n2(n,ss:se) = abs(normrnd(point(s),rnfit,[1 10]));
            else
                n2(n,ss:se)= zeros(1,10);
            end
        end
%         if midpoint(n,c) >0
%             n2(n,:) = abs(normrnd(midpoint(n,c),rnfit,[1 30]));
%         else
%             n2(n,:)= zeros(1,30);
%         end
        
        for m = 1:30
            mm = (c-1)*30 + m;
            TimeMM(:,mm)= mm;
            DataMatmm(n,mm)=grad(n,c)*(mm)+const(n,c); % kWh Usage Per Half Hour with Minute by Minute Data Segments
            DataMatmm30(n,mm)=DataMatmm(n,mm)/30; % kWh Useage Per Minute
            DataMatDem(n,mm)=2*DataMatmm(n,mm);
            DataLiveUse2(n,mm) = n2(n,m)/30;
            DataLiveDem2(n,mm) = 2*n2(n,m);
            % Use a Normally Distributed Random Number to show Change in
            % Usegae Minute by Minute
%           livedatause(n,mm)=2*(DataMatmm(n,mm)+randn/rnfit);
            if DataMatmm(n,mm) == 0
                livedatause(n,mm) = 0;
            else
            livedatause(n,mm)=(DataMatmm(n,mm)+randn/rnfit)/29.995;
            end
            livedatadem(n,mm)=2*29.995*livedatause(n,mm);
        end
        livedataav(n,c)=mean(livedatause(n,mm-29:mm)); % Method to Check the Fit of Code
    end
end

% for t=1:48
%     tb=(t-1)*30+1;
%     tt=t*30;
%     datatest=DataMatmm30(:,[tb:tt]);
%     datasum=sum(datatest');
%     dataconv(:,t)=datasum;
% end

% Create Plots
  for plsct = 3:3
%     figure()
%     yyaxis left;
%     plot(TimeHH(1,:)*60,DataMat(plsct,:))
%     hold on
%     xlim([0 1440]);
%     ylabel('Useage/ kWh')
%     title('Plot of Original Useage and Demand')
%     xlabel('Time / Mins')
%     yyaxis right;
%     plot(TimeMM(1,:),DataMatDem(plsct,:));
%     ylabel('Demand/ kW')
%     
%     figure()
%     plot(TimeMM(1,:),livedatause(plsct,:))
%     ylabel('Useage/kWh')
%     hold on
%     xlim([0 1440]);
%     plot(TimeMM(1,:),DataMatmm30(plsct,:));
%     title('Plot of Live Use Fit Against Minute By Minute Use')
%     xlabel('Time / Minutes')
% 
%     figure()
%     plot(TimeMM(1,:),DataMatDem(plsct,:));
%     xlim([0 1440]);
%     hold on
%     plot(TimeMM(1,:),livedatadem(plsct,:),'g');
%     title('Plot of Live Demand Fit With Minute By Minute Useage Fit')
%     xlabel('Time / Minutes')
%     ylabel('Demand/kW')
%     
    figure()
    plot(TimeMM(1,:),DataMatmm30(plsct,:));
    xlim([0 1440]);
    hold on
    plot(TimeMM(1,:),DataLiveUse2(plsct,:),'r');
    title('Plot of Live Usage Fit 2 With Minute By Minute Useage Fit')
    xlabel('Time / Minutes')
    ylabel('Useage /kWh')
    
  end
  
  
    % Validate Code 
    datasum = sum(DataMat(2,:))
    DataLiveUse2sum = sum(DataLiveUse2(2,:))
    DataLiveDem2sum = trapz(DataLiveDem2(2,:))/60
%     datammsum = sum(DataMatmm30(2,:))
    livedemsum = sum(livedatause(2,:))
%     livesum = trapz(livedatause(2,:))/60
%     datausesum = trapz(DataMatDem(2,:))/60
    
   

