%% Econ with Linprog
%% x = linprog(f,A,b,Aeq,beq,lb,ub)
clc
clear all
%case24_ieee_rts_Libby
case3_ps
gencost=ans.gencost;
Pminmax = [16,20;16,20;15.2,76;15.2,76;16,20;16,20;15.2,76;15.2,76;7,25;7,25;7,25;69,197;69,197;69,197;0,0;2.4,12;2.4,12;2.4,12;2.4,12;2.4,12;54.3,155;54.3,155;100,400;100,400;10,50;10,50;10,50;10,50;10,50;10,50;54.3,155;54.3,155;140,350;];
gencost=horzcat(gencost,Pminmax);
busdata=ans.bus
Pdsum=sum(busdata(:,3))
cmap = hsv(33);  %# Creates a 6-by-3 set of colors from the HSV colormap
X=zeros(200,33);
% figure(1);clf;
% hold on

% for i = 1:33    
%     x=gencost(i,8):1:gencost(i,9)
%     Yp=2*(gencost(i,5)).*x+(gencost(i,6)) %include x^2?
%   plot(x,Yp,'.-','Color',cmap(i,:));  %# Plot each column with a
%                                                #   different color
%     YP(1:length(Yp),i)=Yp; 
% end
f=gencost(:,6)
A=[]
b=[]
Aeq=ones(1,33)
Beq=Pdsum
Lb=gencost(:,8)
Ub=gencost(:,9)
Pgs=linprog(f,A,b,Aeq,Beq,Lb,Ub)
Pgsum=sum(Pgs)

