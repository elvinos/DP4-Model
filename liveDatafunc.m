function [livedatadem, DataMatmm30, DataMat,livedatause] = liveDatafunc(rnfit)

% Script That Turns Half Hourly Useage Data into Minute by Minute Useage
% Data
    fileName = 'senateEDD.csv';

    Data=senateEDD1(fileName);
    rowsData= size(Data,1);
    colsData= size(Data,2);
    DataMat = cell2mat(Data(2:rowsData,4:colsData));
    rowsDataMat = size(DataMat,1);
%     colsDataMat = size(DataMat,2);
    
% TimeMM= zeros(1,1440);
DataMatmm=zeros(rowsDataMat,1440); % kWh Usage Per Half Hour with Minute by Minute Data Segments
DataMatmm30=zeros(rowsDataMat,1440); % kWh Useage Per Minute 29.995 used to give better fit.
livedatause=zeros(rowsDataMat,1440);
livedatadem=zeros(rowsDataMat,1440);
grad=zeros(rowsDataMat,48);
const=zeros(rowsDataMat,48);

    for n=1:rowsDataMat

        for c = 1:48
%             cc= c/2;
%             TimeHH(:,c)= cc;
            cm = c*30;
            if c == 1 %Create a flat gradient for the first 30 mins
                grad(n,c) = ((DataMat(n,c)-DataMat(n,c))/(30));
                const(n,c) = DataMat(n,c)-grad(n,c)*cm;
            else %Use Gradient between points to create Minute by minute useage
                grad(n,c)=((DataMat(n,c)-DataMat(n,c-1))/(30));
                const(n,c)=DataMat(n,c)-grad(n,c)*cm;
            end
            for m = 1:30
                mm = (c-1)*30 + m;
%                 TimeMM(:,mm)= mm;
                DataMatmm(n,mm)=grad(n,c)*mm+const(n,c); % kWh Usage Per Half Hour with Minute by Minute Data Segments
                DataMatmm30(n,mm)=DataMatmm(n,mm)/29.995; % kWh Useage Per Minute 29.995 used to give better fit.
                % Use a Normally Distributed Random Number to show Change in
                % Usegae Minute by Minute
%               livedata(n,mm)=(DataMatmm(n,mm)+randn/rnfit)/29.995;
                livedatadem(n,mm)=(DataMatmm(n,mm)+randn/rnfit)/29.995;
                livedatause(n,mm)=2*29.995*livedatadem(n,mm);
            end
%             livedataav(n,c)=mean(livedata(n,mm-29:mm)); % Method to Check the Fit of Code
        end
    end
end