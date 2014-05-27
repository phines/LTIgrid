function [ delta_Pc_lim ] = lim_lk( delta_Pc,reg_up,reg_down )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
perc=20 %within perc % of our limit


xtop=0:.01:10;
ytop=sigmf(xtop,[(1-perc/100)*5,5]);
ytop=ytop(end:-1:1);
xtop=xtop*perc/10;
xtop=xtop+reg_up*(1-perc/100);
ytop=ytop*reg_up*(1-perc/100);

xbot=0:.01:10;
ybot=sigmf(xbot,[(1-perc/100)*5,5]);
xbot=xbot*perc/10;
xbot=xbot+reg_down;
ybot=ybot*reg_down*(1-perc/100);

xlin=linspace(((1-perc/100)*reg_down)*.995,((1-perc/100)*reg_up)*.995);
ylin=xlin;

x=[xbot,xlin,xtop];
y=[ybot,ylin,ytop];

xx=min(x):.01:max(x);
yy=spline(x,y,xx);

figure;
plot(x,y)
figure;
plot(xx,yy)







end

