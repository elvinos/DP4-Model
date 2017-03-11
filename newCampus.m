%% Clear
clc
close all
clear all

%% Import
tic
fileName1 ='senateEDD.csv';
senateData=senateEDD1(fileName1);
fileName2 ='HallElecData.csv';
hallData=senateEDD1(fileName2);
fileName3 ='JRBLab.csv';
labData=senateEDD1(fileName3);

%% Combine

sdateSenate=char(senateData(2,1));
sdateHall=char(hallData(2,1));
sdateLab=char(labData(2,1));

sdatehall= datenum(sdateHall,'dd/mm/yyyy',2000);
sdatelab= datenum(sdateLab,'dd/mm/yyyy',2000);

rowsData= size(senateData,1);
colsData= size(senateData,2);

numdays = datenum({sdateHall},'dd/mm/yyyy') - datenum({sdateSenate},'dd/mm/yyyy');
nn = 365-numdays;
numdays2 = datenum({sdateLab},'dd/mm/yyyy') - datenum({sdateSenate},'dd/mm/yyyy');
nnn = 365-numdays2;
nnn2= nnn+365;
dn=datestr(datenum(sdatehall)+nn);
dn2=datestr(datenum(sdatelab)+nnn);
dn3=datestr(datenum(sdatelab)+nnn2);

senateDataMat = cell2mat(senateData(2:rowsData,4:colsData));
hallData2= vertcat(hallData(1,:),hallData(nn+2:rowsData,:), hallData(3:nn+2,:));
rowsData2= size(hallData2,1);
colsData2= size(hallData2,2);
labData2= vertcat(labData(1,:),labData(nnn2+2:rowsData,:), labData(3:nnn2+2,:));

sss= 1;
while string(labData2(2,2)) ~= string(senateData(2,2))
    disp(cellstr(labData2(2,2)));
    ss=nnn2+2-sss;
    labData2= vertcat(labData(1,:),labData(ss:rowsData,:), labData(3:ss,:));
    sss=sss+1;
end
sss=1;
while string(hallData2(2,2)) ~= string(senateData(2,2))
    disp(cellstr(hallData2(2,2)));
    ss=nn+2-sss;
    hallData2= vertcat(hallData(1,:),hallData(ss:rowsData,:), hallData(3:ss,:));
    sss=sss+1;
end
    disp('Sucess')
    
hallDataMat = cell2mat(hallData2(2:rowsData2,4:colsData));
labDataMat =cell2mat(labData(2:rowsData,4:colsData));


Data = senateDataMat.*8+labDataMat.*4+hallDataMat.*10;

    
%% Test Vertcat For Data Func
g=3;
senateData1=senateData(2:rowsData,:);

for n=1:2
for gg= g:g+5
    nsav=size(senateData1,1); % TEST
    senateData1 = vertcat(senateData1,senateData(gg:rowsData,:),senateData(g:gg,:));
%     disp(cellstr(senateData1(nsav,2)));
end
 senateData1 = vertcat(senateData1,senateData(2:rowsData,:));
end

for n= 2:size(senateData1,1)-1
    if isequal(cellstr(senateData1(n,2)),cellstr(senateData1(n+1,2)))
        disp([cellstr(senateData1(n,2)),cellstr(senateData1(n+1,2))]);
        disp([cellstr(senateData1(n,2)),cellstr(senateData1(n+1,2))]);
        disp(num2str(n));
    end
end



senateData2= senateData1(:,1:2);
toc