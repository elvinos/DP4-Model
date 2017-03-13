function [livedatause, DataMatmm30, DataMat,sdate] = liveDatafunc(fileName)

% Script That Turns Half Hourly Useage Data into Minute by Minute Useage
% Data

    Data=senateEDD1(fileName);
    sdate=char(Data(2,1));
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

Meandat = mean(mean(DataMat/30));
Maxdat = max(max(DataMat/30));
MnMx = [Meandat,Maxdat];
rnfit= mean(MnMx);
for n=1:rowsDataMat

        for c = 1:48


            cm = c*30;
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
           
            for m = 1:30
                mm = (c-1)*30 + m;
                DataMatmm(n,mm)=grad(n,c)*mm+const(n,c); % kWh Usage Per Half Hour with Minute by Minute Data Segments
                DataMatmm30(n,mm)=DataMatmm(n,mm)/30; % kWh Useage Per Minute 29.995 used to give better fit.
                % Use a Normally Distributed Random Number to show Change in
                % Usegae Minute by Minute
                livedatause(n,mm) = n2(n,m)/30;
                livedatadem(n,mm) = 2*n2(n,m);
            end
    end
end
