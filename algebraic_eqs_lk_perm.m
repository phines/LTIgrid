function [g,dg_dx,dg_dy] = algebraic_eqs(t,x,y,ps,opt) 
% these give us the algebraic equations for the system

global Load_spline

C = psconstants_will;
% extract some useful data about the system
n         = size(ps.bus,1);
ng        = size(ps.gen,1);
mac_bus_i = ps.bus_i(ps.mac(:,1)); % machine bus indices
Xd        = ps.mac(:,C.ma.Xd); % d axis machine reactance
%Pd       = ps.shunt(:,C.sh.P).*ps.shunt(:,C.sh.factor)./ps.baseMVA; % amount of demand
D         = ps.bus_i(ps.shunt(:,1)); % locations of demand
Pd        = (ppval(Load_spline,t))/ps.baseMVA;

% get some indices that allow us to keep track of stuff
ix = get_indices_will(n,ng);
% extract data from the input vectors
theta = y(ix.y.theta); % bus angles
delta = x(ix.x.delta); % machine rotor angles

% calculate the electrical power produced by machines
delta_mac = delta - theta(mac_bus_i); % the rotor angle, relative to the bus angle
Pg = delta_mac./Xd; % the generator power, using the DC load flow assumptions

% calculate the nodal power imbalance:
g = ps.B*theta - sparse(mac_bus_i,1,Pg,n,1) + Pd;%sparse(D,1,Pd,n,1);%CHANGED WHEN CHANGED LOAD STYLE TO ALL BUSES
% power out through transmission lines - power in from gens + power out through loads = 0

% find dg_dx
if nargout>1
    dg_dx = sparse(mac_bus_i,ix.x.delta,-1./Xd,ix.ng,ix.nx);
end
% find dg_dy
if nargout>2
    dg_dy = ps.B + sparse(mac_bus_i,ix.y.theta(mac_bus_i),+1./Xd,ix.ng,ix.ny);
end
