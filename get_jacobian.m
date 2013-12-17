function dfg_dxy = get_jacobian(t,xy,ps)
% This is just a wrapper function to get the system Jacobian

[~,dfg_dxy] = differential_algebraic_eqs_lk_8_27(t,xy,ps);
