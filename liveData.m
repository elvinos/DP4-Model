%% Clear And Close
clc
clear all
close all

%% Variables
plsct = 1; %Select the number of Plots to Create
rnfit = 1; % Select the fit of Different kWh Samples
%% Create Data

fileName = 'senateEDD.csv';

Data=senateEDD1(fileName);
rowsData= size(Data,1);
colsData= size(Data,2);
DataMat = cell2mat(Data(2:rowsData,4:colsData));
rowsDataMat = size(DataMat,1);
colsDataMat = size(DataMat,2);

for n=1:rowsDataMat

    for c = 1:48
        cc= c/2;
        TimeHH(:,c)= cc;
        cm = (c)*30;
        if c == 1 %Create a flat gradient for the first 30 mins
            grad(n,c) = ((DataMat(n,c)-(DataMat(n,c)))/(30));
            const(n,c) = DataMat(n,c)-grad(n,c)*cm;
        else %Use Gradient between points to create Minute by minute useage
            grad(n,c)=((DataMat(n,c)-DataMat(n,c-1))/(30));
            const(n,c)=DataMat(n,c) - grad(n,c)*cm;
        end
        for m = 1:30
            mm = (c-1)*30 + m;
            TimeMM(:,mm)= mm;
            DataMatmm(n,mm)=grad(n,c)*(mm)+const(n,c); % kWh Usage Per Half Hour with Minute by Minute Data Segments
            DataMatmm30(n,mm)=DataMatmm(n,mm)/30; % kWh Useage Per Minute
            % Use a Normally Distributed Random Number to show Change in
            % Usegae Minute by Minute
%             livedatause(n,mm)=2*(DataMatmm(n,mm)+randn/rnfit);
            livedatadem(n,mm)=(DataMatmm30(n,mm)+randn/(rnfit*29.995));
            livedatause(n,mm)=2*29.995*livedatadem(n,mm);
        end
        livedataav(n,c)=mean(livedatause(n,mm-29:mm)); % Method to Check the Fit of Code
    end
end

for t=1:48
    tb=(t-1)*30+1;
    tt=t*30;
    datatest=DataMatmm30(:,[tb:tt]);
    datasum=sum(datatest');
    dataconv(:,t)=datasum;
end

% Create Plots
  for plsct = 2:2
    figure(plsct)
    yyaxis left
    plot(TimeMM(1,:),livedatause(plsct,:))
    ylabel('Demand/kW')
    hold on
%     plot(TimeMM(1,:),DataMatmm(plsct,:));
    xlim([0 1440]);
    yyaxis right
    ylabel('Useage/kWh')
    plot(TimeMM(1,:),DataMatmm30(plsct,:));
    title('Plot of Live Demand Fit With Minute By Minute Useage Fit')
    xlabel('Time / Minutes')
  end
  
    for plsct = 3:3
    figure(plsct)
    plot(TimeMM(1,:),DataMatmm30(plsct,:));
    xlim([0 1440]);
    hold on
    plot(TimeMM(1,:),livedatadem(plsct,:),'g');
    title('Plot of Live Demand Fit With Minute By Minute Useage Fit')
    xlabel('Time / Minutes')
  end
  
  
    % Validate Code 
    datasum = sum(DataMat(2,:))
    datammsum = sum(DataMatmm30(2,:))
    livedemsum = sum(livedatadem(2,:))
    livesum = trapz(livedatause(2,:))/60
    datausesum = trapz(DataMat(2,:))
    
   

