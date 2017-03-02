%% Clear And Close
clc
clear all
close all

%% Model
i=[1 1 1 1 1 1 1 1 1 1];
Cap=100;
CE=0.9;
% f = @(t) i(t);
% 
% SoC(1)=0.5;
% SoC(t)=SoC(1)+(CE/Cap)*integral(f,1,10);

a1 = 0.076;
b1= 13.59;
c1 = 30.99;
a2 = 0.89;
b2  = 3.658;
c2 = 451.9;
k= 1;

for k=1:1000
Q(k)= a1*exp(-((k-b1)/c1)^2) + a2*exp(-((k-b2)/c2)^2);
end
plot(1:1000,Q)