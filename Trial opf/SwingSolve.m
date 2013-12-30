function [dydt] = SwingSolve(t,y,Pm,Eamag,Vinf,H,X12,Xd)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Delta=y(1);
DeltaDot=y(2);

M=H/(pi*60);
D=0.001;
if t>=1 && t<1.1
    PgDelta=0;
else
    PgDelta=((Eamag*abs(Vinf))/(Xd+X12)*sin(Delta));
end
%PMo=3*PgSS

dDeltadt=DeltaDot;
dDeltaDotdt=(Pm-PgDelta-D*DeltaDot)/M;
dydt=[dDeltadt;dDeltaDotdt];


%keyboard
end

