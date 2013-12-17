function [theta] = solve_algebraic_only(ps,delta)
% Solve only the algebraic equations

% prep work and data extraction
ps = dcpf(ps); % run the dc power flow
nmacs = size(ps.mac,1); % get the number of machines
n = size(ps.bus,1); % the number of buses
ix = get_indices(n,nmacs); % index to help us find stuff
omega_0 = 2*pi*60; % normal machine speeds

[x0,y0] = get_xy(ps); % get the state of everything at the current operating point
xy0 = [x0;y0];

% set up the differential equations
fg = @(t,xy) differential_algebraic_eqs(t,xy,ps);

% test the differential equations around the current point
%fg0 = fg(0,xy0);

% solve the ode's
[t,XY] = ode15s(fg,tspan,xy0);

% extract the data from XY
X = XY(:,1:ix.nx);
Y = XY(:,(1:ix.ny) + ix.nx);
delta = X(:,ix.x.delta);
omega = X(:,ix.x.omega_pu) * omega_0; 
Pm =    X(:,ix.x.Pm);
theta = Y;
