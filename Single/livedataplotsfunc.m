function livedataplotsfunc(livedatause, DataMatmm30, DataMat,sdate)
%% Variables
% plsct = 1; %Select the number of Plots to Create

%% Create Data
% NOTE: USE = kWh
%       DEM = kW
TimeMM=zeros(1,1440);
for n= 1:1440
TimeMM(1,n)=n;
end
for n= 0.5:0.5:24
    nn=n*2;
TimeHH(1,nn)=n;
end

% % fileName = 'newCampus.csv';
% [livedatause, DataMatmm30, DataMat,sdate]=liveDatafunc(fileName);
DataMatDem =DataMatmm30*30*2;
livedatadem =livedatause*30*2;

%% Weekly Data Plot
sdatechar=char(sdate);
sdatechar(sdatechar=='''') = []; % Removes addiation quotes placed around string
formatIn = 'dd/mm/yyyy';
strtdate= datenum(sdatechar,formatIn,2000);
[DayNumber,DayName] = weekday(strtdate);
d=0;
while string(DayName) ~= string('Mon')
    d=d+1; 
    [DayNumber,DayName] = weekday(strtdate+d);
%     disp(DayName);
end
strtdate2=strtdate+d;
wkday =1;
wkn=1;
for dd = 1+d:size(livedatause,1)
    if  rem((dd+1)/7,1) == 0  ||  rem((dd)/7,1) == 0
    [DayNumber,DayName] = weekday(strtdate+dd);
%     disp(DayName);
        wknlivedatause(wkn,:)=livedatause(dd,:);
        wkn = wkn+1;
    else
        wklivedatause(wkday,:)=livedatause(dd,:);
        wkday = wkday+1;
    end
end

fullweeks=floor(size(wklivedatause,1)/5);
for w = 1:fullweeks
    for ww= 1:5
        www=(w-1)*5+ww;
        we(ww,:)=wklivedatause(www,:);
    end
    weekk(w,:)=sum(we)/5;
end

%% Monthly Data Plot
datem{1} = strtdate;
[DayNumber,DayName] = weekday(datem{1});
[MonthNum,MonthString] = month(datem{1});
% datem{2}= datem{1}+1;
mcount=1;
mday=1;
Mnth{1}=MonthString;
Day{1}=DayName;
for w = 1:size(livedatause,1)-1
  datem{w+1} = datem{1}+w;
  [MonthNum,MonthString] = month(datem{w+1});
  [DayNumber,DayName] = weekday(datem{w+1});
  Mnth{w+1}=MonthString;
  Day{w+1}=DayName;
  if  string(Day{w}) == string('Sat') || string(Day{w}) == string('Sun')
%         disp(string(Day{w}));
  else
    mdata(mday,:)= livedatause(w,:);
    mday=mday+1;
  end
  if  Mnth{w+1} == Mnth{w}
  else
%       disp(string(Mnth{w}));
%       disp(string(Mnth{w+1}));
    monthdata(mcount,:)=sum(mdata)/size(mdata,1);
    mday=1;
    acMonth{mcount}=Mnth{w};
    mcount = mcount+1; 
  end
end
monthdata(1,:)=(sum(mdata)+monthdata(1,:))/(size(mdata,1)+1);
livedatademcols = livedatadem(:);




%% Create Plots
for plsct = 3:3
    figure()
    subplot(2,2,1);
%     title(sp,datestr(strtdate+plsct-1))
    yyaxis left;
    plot(TimeHH(1,:)*60,DataMat(plsct,:))
    hold on
    xlim([0 1440]);
    ylabel('Useage/ kWh')
    title({'Date: Plot of Original','Useage and Demand'})
    xlabel('Time / Mins')
    yyaxis right;
    plot(TimeMM(1,:),DataMatDem(plsct,:));
    ylabel('Demand/ kW')
    
    subplot(2,2,2);
    plot(TimeMM(1,:),livedatause(plsct,:))
    ylabel('Useage/kWh')
    hold on
    xlim([0 1440]);
    plot(TimeMM(1,:),DataMatmm30(plsct,:));
    title({'Date: Plot of Live Use Fit', 'Against Minute Resoultion'})
    xlabel('Time / Minutes')

    subplot(2,2,3);
    plot(TimeMM(1,:),DataMatDem(plsct,:));
    xlim([0 1440]);
    hold on
    plot(TimeMM(1,:),livedatadem(plsct,:),'g');
    title({'Date: Plot of Live Demand Fit', 'Against Minute Resoultion'})
    xlabel('Time / Minutes')
    ylabel('Demand/kW')
    
    subplot(2,2,4)
    
    histfit(livedatademcols,100)
    xlim([0 max(livedatademcols)]);
    title({'Plot of Frequency of', 'Energy Demand Over a Year'})
    xlabel('Demand/kW')
    ylabel('Frequency')
    text=datestr(strtdate+plsct-1);
    mtit(text,'fontsize',12,'color',[0 0.5 1] ,'xoff',-0.04,'yoff',0.035);
end
  
%% Validate Code 
    datasum = sum(DataMat(2,:));
%     datammsum = sum(DataMatmm30(2,:))
    liveusesum = sum(livedatause(2,:));
%     livesum = trapz(livedatause(2,:))/60
%     datausesum = trapz(DataMatDem(2,:))/60

%% Basic Curve
% Ranked Data (Duration Curve)
figure();
y_data=livedatademcols;
hrs=8760;
tmp_x = (0 : hrs/(length(y_data)-1) : hrs);
plot(tmp_x, sort(y_data, 'descend'), 'LineWidth',2);
hold on;
ylabel('Power Demand');
xlabel('Time/ Hrs');
title('Load Duaration Curve');
grid;

figure()
% subplot(2,1,1)
% plot(TimeMM/60,monthdata);
% xlim([0 1440/60]);
% legend(acMonth)
% xlabel('Time Of Day/Hours')
% ylabel('Energy Usage/kWh')
% subplot(2,1,2)
plot(TimeMM/60,monthdata*30*2);
xlim([0 1440/60]);
legend(acMonth)
xlabel('Time Of Day/Hours')
ylabel('Energy Demand/kW')
title({'Plot of Energy Demand Averaged For Different Months', 'in the Year (Weekdays Only)'})

%% Red Rate Plots
wklivedatausered=wklivedatause(:,1020:1140);
figure()
maxredPDem=max(max(wklivedatausered*30*2));
maxredPUse=max(sum(wklivedatausered,2));
meanredPDem=mean(mean(wklivedatausered*30*2));
meanredPUse=mean(sum(wklivedatausered,2));
mnlivedatausered=monthdata(:,1020:1140);
plot((1020:1140)/60,mnlivedatausered*30*2);
xlim([1020/60 1140/60]);
legend(acMonth)
xlabel('Time Of Red Period /Hours')
ylabel('Energy Demand/kW')
title({'Plot of Red Periods Demand For', 'Different Months in the Year'})
disp(['Max Power Demand in Red Period: ', num2str(maxredPDem), ' kW']);
disp(['Mean Power Demand in Red Period: ', num2str(meanredPDem), ' kW']);
disp(['Max Power Useage in Red Period: ', num2str(maxredPUse), ' kWh']);
disp(['Mean Power Useage in Red Period: ', num2str(meanredPUse), ' kWh']);

%% Unit Charges Plot

figure()
rateR=24.41;
rateA=0.287;
rateG=0.161;

yyaxis left;
plot(TimeMM/60,mean(wklivedatause)*30*2);
xlim([0 1440/60]);
xlabel('Time Of Day/Hours')
ylabel('Energy Demand/kW')
title({'Energy Demand Averaged For All Months', 'Against Unit Rate Costs (Weekdays Only)'})
yyaxis right;
g1=7.5;
a2=17;
r3=19;
a4=21.5;
g5=24;
cola=[251 250 48] ./ 255;
colr=[170  0 0] ./ 255;
colg=[12 195 82] ./ 255;
alpha= 0.4;
bar(g1/2,rateG,g1,'FaceColor', colg,'FaceAlpha',alpha);
hold on
bar(g1+((a2-g1)/2),rateA,a2-g1,'FaceColor', cola,'FaceAlpha',alpha);
bar(a2+((r3-a2)/2),rateR,r3-a2,'FaceColor', colr,'FaceAlpha',alpha);
bar(r3+((a4-r3)/2),rateA,a4-r3,'FaceColor', cola,'FaceAlpha',alpha);
bar(a4+((g5-a4)/2),rateG,g5-a4,'FaceColor', colg,'FaceAlpha',alpha);
ylim([0 24]);
ylabel('Cost per kWh / Pence')

end