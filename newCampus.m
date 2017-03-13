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
%     disp(cellstr(labData2(2,2)));
    ss=nnn2+2-sss;
    labData2= vertcat(labData(1,:),labData(ss:rowsData,:), labData(3:ss,:));
    sss=sss+1;
end
sss=1;
while string(hallData2(2,2)) ~= string(senateData(2,2))
%     disp(cellstr(hallData2(2,2)));
    ss=nn+2-sss;
    hallData2= vertcat(hallData(1,:),hallData(ss:rowsData,:), hallData(3:ss,:));
    sss=sss+1;
end
    disp('Sucess')
    
hallDataMat = cell2mat(hallData2(2:rowsData2,4:colsData));
labDataMat =cell2mat(labData(2:rowsData,4:colsData));

Data = senateDataMat.*7.9+labDataMat.*4+hallDataMat.*7.6;
Datacell = num2cell(Data);
datatot= num2cell(sum(Data,2));
sendat= senateData(2:size(senateData,1),1:2);
Dataexp = horzcat(sendat,datatot,Datacell);
Dataexp2 = vertcat(senateData(1,:),Dataexp);
datacols1=Dataexp2(1:366,1:3);
datacols2=Dataexp2(1:366,4:colsData);

%% WRITE FILE - DOES NOT WORK Copy and Paste Values

% filename = 'newCampus1.csv';
% fid = fopen(filename, 'w') ;
% fprintf(fid, '%f %f %f\n', datacols1{:,:}) ;
% % fprintf(fid, '%s\n', Dataexp{1,end}) ;
% fclose(fid) ;
% dlmwrite(filename, datacols2(:,:), '-append') ;
% filename2 = 'newCampus2.csv';
% csvwrite(filename2,Dataexp2)
% xlswrite(filename,Dataexp2(1:2,3:51))
%% Test Vertcat For Data Func
% g=2;
% Data1=Data;
% rowsData= size(Data,1);
% colsData= size(Data,2);

% for n=1:2
% for gg= g:g+5
%     nsav=size(Data,1); % TEST
%     Data = vertcat(Data,Data1(gg:rowsData,:),Data1(g:gg,:));
% end
%  Data = vertcat(Data,Data1);
% end
toc