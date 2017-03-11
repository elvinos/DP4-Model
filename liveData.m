%% Clear And Close
clc
clear all
close all
 
%% Variables
plsct = 1; %Select the number of Plots to Create

%% Create Data
% NOTE: USE = kWh
%       DEM = kW
fileName = 'senateEDD.csv';
[livedatause, DataMatmm30, DataMat,sdate]=liveDatafunc(fileName);
TimeMM=zeros(1,1440);
for n= 1:1440
TimeMM(1,n)=n;
end

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
    plot(TimeMM(1,:),livedatause(plsct,:),'r');
    title('Plot of Live Usage Fit 2 With Minute By Minute Useage Fit')
    xlabel('Time / Minutes')
    ylabel('Useage /kWh')
    
  end
  
    % Validate Code 
    datasum = sum(DataMat(2,:))
%     datammsum = sum(DataMatmm30(2,:))
    liveusesum = sum(livedatause(2,:))
%     livesum = trapz(livedatause(2,:))/60
%     datausesum = trapz(DataMatDem(2,:))/60
    
   

