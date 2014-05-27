%% driver that tests the f and g equations for 9-bus case
clear all; close all; clc; 

%% load the data
C = psconstants;
ps = case9_ps; % get the real one?
ps = updateps(ps);
ps = dcpf(ps); % dc power flow
tmax = 100;
ps0 = ps;
nmacs = size(ps.gen,1);
n = size(ps.bus,1);
ix = get_indices(n,nmacs); % index to help us find stuff
opt = psoptions;

% prepare the machine state variables
ps.mac = get_mac_state(ps,'linear');

% build x and y
[x0,y0] = get_xy(ps);

%% check derivatives for differential equations
%% check df_dx
x = x0; y = y0;
fprintf('\nChecking df_dx for x0\n');
[f0,df_dx,df_dy] = differential_eqs(0,x,y,ps,opt);
f_handle = @(x) differential_eqs(0,x,y,ps,opt);
checkDerivatives(f_handle,df_dx,x);
% repeat from a perturbed starting point
disp('Checking df_dx for perturbed x0');
x = x0+randn(size(x0))*0.1;
[f0,df_dx,df_dy] = differential_eqs(0,x,y,ps,opt);
checkDerivatives(f_handle,df_dx,x);

%% check df_dy
x = x0; y = y0;
fprintf('\nChecking df_dy for y0\n');
[f0,df_dx,df_dy] = differential_eqs(0,x,y,ps,opt);
f_handle = @(y) differential_eqs(0,x,y,ps,opt);
checkDerivatives(f_handle,df_dy,y);
% repeat from a perturbed starting point
disp('Checking df_dy for perturbed y0');
y = y0+randn(size(y0))*0.1;
[f0,df_dx,df_dy] = differential_eqs(0,x,y,ps,opt);
checkDerivatives(f_handle,df_dy,y);

%% check dg_dx
x = x0; y = y0;
fprintf('\nChecking dg_dx for x0\n');
[f0,dg_dx,dg_dy] = algebraic_eqs(0,x,y,ps,opt);
g_handle = @(x) algebraic_eqs(0,x,y,ps,opt);
checkDerivatives(g_handle,dg_dx,x);
% repeat from a perturbed starting point
disp('Checking dg_dx for perturbed x0');
x = x0+randn(size(x0))*0.1;
[f0,dg_dx,dg_dy] = algebraic_eqs(0,x,y,ps,opt);
checkDerivatives(g_handle,dg_dx,x);

%% check dg_dy
x = x0; y = y0;
fprintf('\nChecking dg_dy for y0\n');
[f0,dg_dx,dg_dy] = algebraic_eqs(0,x,y,ps,opt);
g_handle = @(y) algebraic_eqs(0,x,y,ps,opt);
checkDerivatives(g_handle,dg_dy,y);
% repeat from a perturbed starting point
disp('Checking dg_dy for perturbed y0');
y = y0+randn(size(y0))*0.1;
[f0,dg_dx,dg_dy] = algebraic_eqs(0,x,y,ps,opt);
checkDerivatives(g_handle,dg_dy,y);

return
