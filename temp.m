P    = 0:10000;
Plim = zeros(length(P),1);
Pmin = P(end)*0.1;
Pmax = P(end)*0.9;
dxcheck = zeros(length(P),1);
for i=1:length(P)
    [dx,x]=limiter_cosmic(P(i),Pmax,Pmin);
    Plim(i)=x;
    dxcheck(i)=dx;
end

P2 = 8990:.0001:9010;
Plim2 = zeros(length(P2),1);
Pmin2 = Pmin;
Pmax2 = Pmax;
dxcheck2 = zeros(length(P2),1);
for i=1:length(P2)
    [dx,x]=limiter_cosmic(P2(i),Pmax2,Pmin2);
    Plim2(i)=x;
    dxcheck2(i)=dx;
end
P3 = 990:.0001:1010;
Plim3 = zeros(length(P3),1);
Pmin3 = Pmin;
Pmax3 = Pmax;
dxcheck3 = zeros(length(P3),1);
for i=1:length(P3)
    [dx,x]=limiter_cosmic(P3(i),Pmax3,Pmin3);
    Plim3(i)=x;
    dxcheck3(i)=dx;
end
%%
close all
figure(1)
title('Something')
subplot(4,2,1)
plot(P,Plim)
title('Limiter Function')
subplot(4,2,3)
plot(P(900:1500),Plim(900:1500),'r')
hold on
plot(1000.8,1000.8,'b.')
title('Limiter Function at Lower Limit')
axis([-Inf Inf -Inf Inf])
subplot(4,2,5)
plot(P(8500:9100),Plim(8500:9100),'r')
hold on
plot(8999.2,8999.2,'b.')
title('Limiter Function at Upper Limit')
axis([-Inf Inf -Inf Inf])
subplot(4,2,7)
plot(P3(107990:108010),dxcheck3(107990:108010),'r')
axis([-Inf Inf -Inf Inf])
title('Limiter Function Derivative at Lower Limit,Zoomed')
subplot(4,2,2)
plot(P,dxcheck)
title('Limiter Function Derivative')
subplot(4,2,4)
plot(P(900:1500),dxcheck(900:1500),'r')
axis([-Inf Inf -Inf Inf])
title('Limiter Function Derivative at Lower Limit')
subplot(4,2,6)
plot(P(8500:9100),dxcheck(8500:9100),'r')
title('Limiter Function Derivative at Upper Limit')
axis([-Inf Inf -Inf Inf])
subplot(4,2,8)
plot(P2(91990:92010),dxcheck2(91990:92010),'r')
axis([-Inf Inf -Inf Inf])
title('Limiter Function Derivative at Upper Limit,Zoomed')



% %%
% P=0:6
% Pmin=1
% Pmax=5
% Plim=zeros(length(P),2)
% for i=1:length(P)
%     [dx,x]=limiter(P(i),Pmax,Pmin);
%     Plim(i,2)=x;
% end
% 
% figure(2)
% %plot(P)
% hold on
% plot(Plim)