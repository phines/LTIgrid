function [x y] = get_xy(ps)
% usage: [x,y] = get_xy(ps)
% this function gets the x and y vectors from the data in ps
% this is used for the simple/LTI grid model

C  = psconstants_will;

% get some constants
ng = size(ps.gen,1);
n  = size(ps.bus,1);
ix = get_indices_will(n,ng);
G  = ps.bus_i(ps.mac(:,1));

% get data from the ps structure
omega_0  = 2*pi*ps.frequency;
theta    = ps.bus(:,C.bu.Vang)*pi/180;
delta_m  = ps.mac(:,C.ma.delta_m);
delta    = delta_m + theta(G);
omega_pu = ps.mac(:,C.ma.omega)/omega_0;
Pm       = ps.mac(:,C.ma.Pm);
delta_Pc = ps.gen(:,C.ge.P)/ps.baseMVA - Pm;

% build x
x = zeros(ix.nx,1);
x(ix.x.delta)    = delta;
x(ix.x.omega_pu) = omega_pu;
x(ix.x.Pm)       = Pm;
x(ix.x.delta_Pc) = delta_Pc;  
% build y
y = zeros(ix.ny,1);
y(ix.y.theta) = theta;