%% Clear And Close
clc
clear all
close all

%% Variables
plsct = 1; %Select the number of Plots to Create

% Rates in Pence
UnitRate = 6.832;
rateR=24.41;
rateA=0.287;
rateG=0.161;

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
    Time(:,cc)= c;
end

%% Costs
Rtot = zeros(rowsDataMat,colsDataMat);
Atot = zeros(rowsDataMat,colsDataMat);
Gtot = zeros(rowsDataMat,colsDataMat);
DUoSCharge = zeros(rowsDataMat,colsDataMat);
HHcharge = zeros(rowsDataMat,colsDataMat);
Daycharge=zeros(rowsDataMat,1);


% Calculate Unit Charge
for n=1:rowsDataMat

    for c = 1:48
        
    if  rem((n+6)/7,1) == 0  ||  rem((n)/7,1) == 0 % Finds Sundays + Saturdays
        if 17 < Time(1,c) && Time(1,c) <= 19.5
            DUoSrate = rateA;
            Atot(n,c)= DataMat(n,c)*rateA;
        else
            DUoSrate = rateG;
            Gtot(n,c)= DataMat(n,c)*rateG;
        end
    else
        if  Time(1,c) <= 19 && Time(1,c) > 17
            DUoSrate = rateR;
            Rtot(n,c)= DataMat(n,c)*rateR;
        elseif 8 < Time(1,c) && Time(1,c) <= 17 || 19 < Time(1,c) && Time(1,c) <= 21.5
            DUoSrate = rateA;
            Atot(n,c)= DataMat(n,c)*rateA;
        else
            DUoSrate = rateG;
            Gtot(n,c)= DataMat(n,c)*rateG;
        end
        
    end
    DUoSCharge(n,c)= DataMat(n,c)*DUoSrate;
    HHcharge(n,c) = DataMat(n,c)*(DUoSrate+UnitRate);
    end
    Daycharge(n,:)= sum(HHcharge(n,:))./100; %Daily Cost in Pounds
end
plot(Time(1,:),Rtot(2,:),'r--');
hold on
plot(Time(1,:),Atot(2,:),'y--');
plot(Time(1,:),Gtot(2,:),'g--');
chargeR=sum(sum(Rtot))/100;
chargeA=sum(sum(Atot))/100;
chargeG=sum(sum(Gtot))/100;
% totunitDUoS=(chargeR/rateR+chargeA/rateA+chargeG/rateG)*100
DUoSTot= sum(sum(DUoSCharge))/100;
TotUnit= sum(sum(DataMat));
Yearcharge = sum(Daycharge)
Saving = chargeR

