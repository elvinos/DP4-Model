%% Simple Simulink File
% use this file to calculate parameters
% and make them available to Simulink.
clc;clear;

%% Parameters
% Gain1=3; 
% SP=1.25;
% ICpos=-0.5; 
% recipJ=1/2.0;
% Drag=0.55;
% sim('ServoDemo.mdl');

%% Display results from ScopeData
% Time=tout;
% Vel=ScopeData.signals(1).values;
% Pos=ScopeData.signals(2).values;
% plot(Time,Vel, Time,Pos);grid on;

%get the values in the Excel using xlsread.
[time,txt] = xlsread(testdata,sheet1,A1:B49);
%combine data as you want:
AllData={txt;time};%as you want
%save in mat file
save(testdata,'AllData');%In your matfile name
