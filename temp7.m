%% Calculate cubic functions
% Ru=0.01;
% Ru_frac=0.99*Ru;
% 
% M=[Ru_frac^3 Ru_frac^2 Ru_frac 1;Ru^3 Ru^2 Ru 1; 3*(Ru_frac^2) 2*Ru_frac 1 0;3*(Ru^2) 2*Ru 1 0];
% Y=[1;0;0;0];
% coefs=M\Y;

Rd=-0.01
Rd_frac=0.99*Rd;

M=[Rd_frac^3 Rd_frac^2 Rd_frac 1;Rd^3 Rd^2 Rd 1; 3*(Rd_frac^2) 2*Rd_frac 1 0;3*(Rd^2) 2*Rd 1 0];
Y=[1;0;0;0];
coefs=M\Y;

delta_Pc=Rd:(Rd_frac-Rd)/100:Rd_frac;
a=coefs(1);
b=coefs(2);
c=coefs(3);
d=coefs(4);
delta_Pc_dot_lim=(a.*delta_Pc.^3+b.*delta_Pc.^2+c.*delta_Pc+d);

cubic = spline(delta_Pc,delta_Pc_dot_lim);

%% plot cubic
figure(1);
plot(delta_Pc,delta_Pc_dot_lim)



