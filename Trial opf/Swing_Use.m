%Swing Use
PgSS=0.5
Eamag=1.8
Vinf=1
H=5
X12=0.4
Xd=1
D=0.001

Delta=asin(PgSS*(Xd+X12)/Eamag/Vinf)
DeltaDot=0
y0=[Delta;DeltaDot]
SwingSolve(0,y0,PgSS,Eamag,Vinf,H,X12,Xd)
f=@(t,y)SwingSolve(t,y0,PgSS,Eamag,Vinf,H,X12,Xd)
o=odeset('InitialStep',0.01)
[t1,y1]=ode45(f,[0,1],y0,o);
y0=y1(end,:)';
[t2,y2]=ode45(f,[1,1.01],y0,o);

y0=y2(end,:)';
keyboard
[t3,y3]=ode45(f,[1.1,5],y0,o);
t=[t1;t2;t3]
y=[y1;y2;y3]
plot(t,y)