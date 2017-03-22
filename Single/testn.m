% figure()
% range=30;
% x=sizeR3(1:range);
% y=sortpbtime(1:range);
xpb=sizeRange;
ypb=pbtime;
hold on
fitrange=4;
polyn=4;
mxmin='ascend';
[xfitpb,pfitpb] = maxFitfunc(xpb,ypb,fitrange,polyn,mxmin);
plot(xfitpb,pfitpb,'Color', Colnpv(3,:),'linewidth', 1.5) 
% [xfit,pfit] = maxFitfunc(x,y,fitrange,polyn,mxmin);
% plot(xfit,pfit)  