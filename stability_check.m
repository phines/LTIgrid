function [ output_args ] = stability_check(df_dx,df_dy,dg_dx,dg_dy)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Stab           = df_dx-df_dy*inv(dg_dy)*dg_dx; %better way than inv?
evals          = eigs(Stab);
real_evals     = real(evals);
max_real_evals = max(real_evals)


Stab_full           = full(Stab); 
evals_full          = eig(Stab_full);
real_evals_full     = real(evals_full);
max_real_evals_full = max(real_evals_full)
num_pos_evals       = length(find(real_evals_full>0))
end

