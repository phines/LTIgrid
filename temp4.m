delta_Pc_dot=50
% matlab
x=0:.1:10;
y=sigmf(x,[2,5]);
y=y(end:-1:1);
y=y-1;
x=x/max(x)*(Reg_down*(1-perc/100)-Reg_down);
x=x+Reg_down;
y=y*abs(delta_Pc_dot);
% delta_Pc_dot_lim_up_sigm = spline(x,y);
% delta_Pc_dot_lim = ppval(delta_Pc_dot_lim_up_sigm,delta_Pc);

% full function
a=2;
c=5;
x2=0:.1:10;
scalex = (Reg_down*(1-perc/100)-Reg_down)/max(x2);
%scalex=1
x2=-100:.1:-80 %increase x so it actually plots the whole thing
%y2=(1./(1+exp(a*(x2/scalex-c))))-1;
y2=abs(delta_Pc_dot)*((1./(1+exp(a/scalex*((x2-Reg_down)-c*scalex))))-1);
figure(1);clf;
% subplot(3,1,1);hold on;
% plot(x,y,'b')
% plot(x2,y2,'g')
% subplot(3,1,2)
plot(x,y,'b')
% subplot(3,1,3)
% plot(x2,y2,'g')