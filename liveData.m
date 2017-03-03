%% Clear And Close
clc
clear all
close all

%% Variables
plsct = 1; %Select the number of Plots to Create

%% Create Data

fileName = 'senateEDD.csv';

Data=senateEDD1(fileName);
rowsData= size(Data,1);
colsData= size(Data,2);
DataMat = cell2mat(Data(2:rowsData,4:colsData));
rowsDataMat = size(DataMat,1);
colsDataMat = size(DataMat,2);

for c = 0.5:0.5:24
    cc= c*2;
    TimeHH(:,cc)= c;
end
for mm = 0:1:1439
    TimeMM(:,mm+1)= mm;
end


for n=1:rowsDataMat

    for c = 1:48
        if c - 1 == 0
            grad(n,c) = 1;
        else
        grad(n,c)=((DataMat(n,c))-(DataMat(n,c-1))/(30)); 
        end
        const(n,c)=DataMat(n,c)-grad(n,c)*(c-1)*30;
        for m = 1:30
        mm = (c-1)*30 + m;
        livedata(n,mm)=2*(DataMat(n,c)+randn/5);
%         livedata(n,mm)=2*(DataMat(n,c));
        DataMatmm(n,mm)=grad(n,c)*mm+const(n,c);
        end
        livedataav(n,c)=mean(livedata(n,mm-29:mm));
    end
end

for m = 1:30
      test(m)=livedata(1,m);
end
    
   test = mean(test);
   disp(DataMat(1,1));
%     plot(TimeMM(1,:),livedata(1,:))
    hold on
    plot(TimeMM(1,:),DataMatmm(1,:));
%     ylim([8 38]);
    xlim([0 1440]);
%     plot(TimeHH(1,:)*60,DataMat(1,:));
%     plot(TimeHH(1,:)*60,livedataav(1,:));
    datasum = sum(DataMat(1,:));
    livesum = trapz(livedata(1,:))/60;
    