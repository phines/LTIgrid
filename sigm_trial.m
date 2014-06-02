% t=-5:.01:5;
% A=0; %lower asymptote
% K=1; %upper asymptote
% B=3; %growth rate
% Q=0.5; %depends on the value of Y(0)
% v=0.5; %>0 affects near which asymptote maximum growth occurs
% M=0;  %time of maximum growth if Q=v
% Y=A+(K-A)./((1+Q*exp(-B*(t-M))).^(1/v));
% figure(1);clf;
% plot(t,Y)
delta_Pc_dot=50
t=10:.01:100;
Reg_up = 100
perc=1
A=delta_Pc_dot; %lower asymptote
K=0; %upper asymptote
B=75; %growth rate
Q=1; %depends on the value of Y(0)
v=1; %>0 affects near which asymptote maximum growth occurs
M=0;
ysub_check = (K-A)./((1+Q*exp(-B*(t-M))).^(1/v));
Y=A+(K-A)./((1+Q*exp(-B*(t-M))).^(1/v));
a=find(Y==K,1);
tshift=t(a);
M=Reg_up-tshift;  %time of maximum growth if Q=v (horizontal shift)
Y=A+(K-A)./((1+Q*exp(-B*(t-M))).^(1/v));
% b=find(Y==A,1,'last');
% c=find(Y==K,1);
% t=t(b:c)
% Y=Y(b:c)
figure(2);clf;
plot(t,Y)
axis([-Inf Inf 0 50])
lk=[t;Y];
lk1=find(Y<26 & Y>24);
lk1=lk(:,lk1)

delta_Pc_dot=-50;
t=-110:.01:10;
Reg_down = -100;
perc=1;
A=0; %lower asymptote
K=delta_Pc_dot; %upper asymptote
B=75; %growth rate
Q=1; %depends on the value of Y(0)
v=1; %>0 affects near which asymptote maximum growth occurs
M=0;
ysub_check = (K-A)./((1+Q*exp(-B*(t-M))).^(1/v));
Y=A+(K-A)./((1+Q*exp(-B*(t-M))).^(1/v));
a=find(Y<A-1e-14,1);
tshift=t(a);
M=Reg_down-tshift;  %time of maximum growth if Q=v (horizontal shift)
Y=A+(K-A)./((1+Q*exp(-B*(t-M))).^(1/v));
b=find(Y<A-1e-14,1);
c=find(Y==K,1);
t=t(b:c);
Y=Y(b:c);
figure(3);clf;
plot(t,Y)
axis([-Inf Inf -50 0])
lk=[t;Y];
lk1=find(Y>-26 & Y<-24);
lk1=lk(:,lk1)