clc
clear all

global Pcdotlim_Ru_spline dPcdotlim_dPc_upsp dPcdotlim_dPcdot_upsp Pcdotlim_Rd_spline dPcdotlim_dPc_downsp dPcdotlim_dPcdot_downsp

Reg_up=0.01;
Reg_down=-0.01;

[Pcdotlim_Ru_spline,dPcdotlim_dPc_upsp,dPcdotlim_dPcdot_upsp] = Pcdotlim_upspline(Reg_up);
[Pcdotlim_Rd_spline,dPcdotlim_dPc_downsp,dPcdotlim_dPcdot_downsp] = Pcdotlim_downspline(Reg_down);

for i=1:100000
delta_Pc_dot   = randn(1)*0.01; 
delta_Pc_check = randn(1)*0.01; 
check = @(delta_Pc_check)Pcsplinetrial_V4(delta_Pc_check, delta_Pc_dot,Reg_up,Reg_down);

n_errs = checkDerivatives2(check,[],delta_Pc_check);
    if n_errs>0
        keyboard
    end
end