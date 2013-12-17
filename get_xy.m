function [x,y] = get_xy(ps)
% this function gets the x and y vectors from the data in ps
% this is used for the simple/LTI grid model

% get some constants
ng = size(ps.gen,1);
n  = size(ps.bus,1);
ix = get_indices(n,ng);
C = psconstants;

% get data from the ps structure
mac_bus_i = ps.bus_i(ps.mac(:,1));
omega_0  = 2*pi*ps.frequency;
theta    = ps.bus(:,C.bu.Vang)*pi/180;
delta    = ps.mac(:,C.ma.delta_m) + theta(mac_bus_i);
omega_pu = ps.mac(:,C.ma.omega)/omega_0;
Pm       = ps.mac(:,C.ma.Pm);

% build x
x = zeros(ix.nx,1);
x(ix.x.delta)    = delta;
x(ix.x.omega_pu) = omega_pu;
x(ix.x.Pm)       = Pm;
% build y
y = zeros(ix.ny,1);
y(ix.y.theta) = theta;

