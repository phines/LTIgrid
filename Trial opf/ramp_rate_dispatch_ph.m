function [gen_dispatch,sensitivities] = ramp_rate_dispatch(delta_t,demand,G0,gen_cost,gen_limits,ramp_rates)
% solve an optimal dispatch problem with ramp-rate constraints
% Inputs:
%  delta_t: time step size in minutes
%  Demand for each time period  in MW (n_t x 1, where n_t is the number of time periods)
%  G0 is the initial generaton at time 0 (MW)
%  generator costs for each power plant ($/MWh) (n_g x 1)
%  Minimum and maximum generation in MW (n_g x 2 matrix)
%  Up and down ramp rates for each generator (MW per minute, n_g x 2 matrix)
% Outputs:
%  gen_dispatch, Pg for each time period in MW (n_g x n_t) matrix 
%  sensitivities, a structure sensitivities
%    TODO: describe what is in it...

% extract some useful constants
% check delta 1
if ~isscalar(delta_t), error('delta_t is not a scalar'); end
% num of demand periods
n_t = size(demand,1);
if n_t<=1, error('something looks wrong in your demand vector.'); end
% num of generators
n_g = size(G0,1);
% check gen costs
if size(gen_cost,1)<=1, error('something looks wrong in your fuel costs.'); end
% check gen_limits
if any(size(gen_limits)~=[n_g,2])
    error('gen_limits not correct');
end
Gmin = gen_limits(:,1);
Gmax = gen_limits(:,2);

% check ramp_rates
if any(size(ramp_rates)~=[n_g,2])
    error('ramp_rates not correct');
end
RRD = -abs(ramp_rates(:,1) * delta_t);
RRU = +abs(ramp_rates(:,2) * delta_t);
% initialize the outputs
gen_dispatch = zeros(n_g,n_t);
sensitivities = [];

%% build the problem formulation

% build a variable index if needed
 % not needed yet
nx = n_g * n_t;

% cost coefficients and variable bounds
c   = zeros(nx,1);
x_L = zeros(nx,1);
x_U = zeros(nx,1);
for k = 1:n_t
    vars = (1:n_g) + (k-1)*n_g;
    % cost
    c(vars) = gen_cost;
    % lower bounds
    x_L(vars) = Gmin;
    % upper bounds
    x_U(vars) = Gmax;
end
% adjust the limits for the first period
vars = (1:n_g);
x_L(vars) = max(Gmin,G0+RRD);
x_U(vars) = min(Gmax,G0+RRU);

% build the supply/demand constraints
A_sd = sparse(n_t,nx); % supply/demand
b_L_sd = demand;
b_U_sd = demand;
for k = 1:n_t
    row = k;
    cols = (1:n_g) + (k-1)*n_g;
    A_sd = A_sd + sparse(row,cols,1,n_t,nx);
end

% build the ramp rate constraints
% G(i,k-1) + RRD(i) <= G(i,k)
% G(i,k-1) + RRU(i) <= G(i,k)
n_rr_cons = (n_t-1)*n_g;
A_ru  = sparse(n_rr_cons,nx); % ramp up
A_rd  = sparse(n_rr_cons,nx); % ramp down
b_L_rd = zeros(n_rr_cons,1);
b_U_rd = zeros(n_rr_cons,1);
b_L_ru = zeros(n_rr_cons,1);
b_U_ru = zeros(n_rr_cons,1);

for k=2:n_t
    rows = (1:n_g) + (k-2)*n_g;
    cols_cur  = (1:n_g) + (k-1)*n_g;
    cols_prev = (1:n_g) + (k-2)*n_g;
    A_ru = A_ru + sparse(rows,cols_cur ,+1,n_rr_cons,nx);
    A_ru = A_ru + sparse(rows,cols_prev,-1,n_rr_cons,nx);
    A_rd = A_rd + sparse(rows,cols_cur ,+1,n_rr_cons,nx);
    A_rd = A_rd + sparse(rows,cols_prev,-1,n_rr_cons,nx);
    libb=full(A_ru);
    b_L_rd(rows) = RRD;
    b_U_rd(rows) = +Inf;
    b_L_ru(rows) = -Inf;
    b_U_ru(rows) = RRU;
end

% assemble the constraints together
A = [A_sd;A_ru;A_rd];
b_L = [b_L_sd;b_L_ru;b_L_rd];
b_U = [b_U_sd;b_U_ru;b_U_rd];


% build a test x
x0 = zeros(nx,1);
for k=1:n_t
    rows = (1:n_g) + (k-1)*n_g;
    x0(rows) = G0;
end
b = A*x0;
b_test = [b_L b b_U]
x_test = [x_L x0 x_U]

[x,lambda,status] = solvelp(c,x_L,x_U,A,b_L,b_U);

if status==1
    for k=1:n_t
        rows = (1:n_g) + (k-1)*n_g;
        x_k = x(rows);
        gen_dispatch(:,k) = x_k;
    end
else
    error('could not solve the problem');
end

