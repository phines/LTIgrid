function [ delta_Pc_dot_lim_sp,dPcdotlim_dPc_sp,dPcdotlim_dPcdot_sp] = Pcdotlim_upspline( Ru_vec )
%Forms a cubic spline which drops from 1 down to 0 to be used to smoothly
%limit Pcdot

%% Calculate cubic functions
for i=1:length(Ru_vec)
    Ru=Ru_vec(i);
    Ru_frac=0.99*Ru;
    
    M=[Ru_frac^3 Ru_frac^2 Ru_frac 1;Ru^3 Ru^2 Ru 1; 3*(Ru_frac^2) 2*Ru_frac 1 0;3*(Ru^2) 2*Ru 1 0];
    Y=[1;0;0;0];
    coefs=M\Y;
    
    delta_Pc=Ru_frac:(Ru-Ru_frac)/100:Ru;
    a=coefs(1);
    b=coefs(2);
    c=coefs(3);
    d=coefs(4);
    delta_Pc_dot_lim=(a.*delta_Pc.^3+b.*delta_Pc.^2+c.*delta_Pc+d);
    
    delta_Pc_dot_lim_sp(i) = spline(delta_Pc,delta_Pc_dot_lim);
    
    %% calculate derivs
    dPcdotlim_dPc       = 3.*a.*delta_Pc.^2+2.*b.*delta_Pc+c; %needs to be multiplied by delta_Pc_dot to be the full deriv
    dPcdotlim_dPc_sp(i)    = spline(delta_Pc, dPcdotlim_dPc);
    
end
dPcdotlim_dPcdot_sp = delta_Pc_dot_lim_sp;
end

