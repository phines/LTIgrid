function [max_real_evals,num_pos_evals] = stability_check(df_dx,df_dy,dg_dx,dg_dy,ps)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Stab           = df_dx-df_dy*inv(dg_dy)*dg_dx; %better way than inv?
evals          = eigs(Stab);
real_evals     = real(evals);
max_real_evals = max(real_evals);
num_pos_evals       = length(find(real_evals>0));
figure; hold on
plot(real(evals),imag(evals),'.')
plot(-1:.001:0,0,'r')
plot(0,-10:.01:10,'r')
title(['K = ',num2str(ps.areas(1,1))])

Stab_full           = full(Stab); 
evals_full          = eig(Stab_full);
real_evals_full     = real(evals_full);
max_real_evals_full = max(real_evals_full);
num_pos_evals_full  = length(find(real_evals_full>0));
figure; hold on
plot(-1:.001:0,0,'r')
plot(0,-10:.01:10,'r')
plot(real(evals_full),imag(evals_full),'.')
title(['K = ',num2str(ps.areas(1,1)),' full'])
end

