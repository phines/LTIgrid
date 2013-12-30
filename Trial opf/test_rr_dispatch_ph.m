%test_dispatch
clear all;
% add mexosi to the path
%addpath([pwd '/mexosi']);

% TODO: get these data from files
delta_t = 1;
fuel_cost = [1 2]';
heat_rate = [1 2]';
gen_cost = fuel_cost.*heat_rate;
demand = [1 2 1 1.5 2 1.8]';
n_g = 2;
gen_limits = [zeros(n_g,1) ones(n_g,1)];
ramp_rates = [-ones(n_g,1) +ones(n_g,1)] / 2;
G0 = [.5;.5];

keyboard
[gen_dispatch,sensitivities] = ramp_rate_dispatch_ph(delta_t,demand,G0,gen_cost,gen_limits,ramp_rates);

gen_dispatch
sensitivities
