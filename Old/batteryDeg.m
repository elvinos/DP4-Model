%% Clear And Close
clc
clear all
close all

%% Call Battery Use
tic
batteryuse= batteryuse();
curCap2=200;
noCycles= 5000;
endlife= 0.8;
perCycleDeg=(curCap2-curCap2*endlife)/noCycles;
y= 1;
use= 0;
cycle = 0;
n=0;

batteryuse2=vertcat(batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse,batteryuse);
batteryuse3=batteryuse2;
negbats= find(batteryuse3<0);
batteryuse3(negbats)=0;
% batteryuse3(batteryuse3<0)=[];
% rowsBatUse = size(batteryuse3,1);
% colsBatUse = size(batteryuse3,2);

%% Loop

h = waitbar(0,'Please wait...');

while curCap2 > 160
n=n+1;
   for c= 1:1440
       curCap2=curCap2-(batteryuse3(n,c)*perCycleDeg/curCap2);
       Cap(n,c)=curCap2;
       use = batteryuse3(n,c)+use;
       if curCap2 <= use
       cycle=cycle + 1;
       use = use-curCap2;
       end
   end
 waitbar((200-Cap(n,c))/ 40)   
end
close(h)
totbatteryuse = batteryuse3(1:n,:);
disp(n)
disp(cycle)
toc


