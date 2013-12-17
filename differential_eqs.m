function [f,df_dx,df_dy] = differential_eqs(t,x,y,ps,opt)
% usage: [f,df_dx,df_dy] = differential_eqs(t,x,y,ps,opt)
% differential equation that models the elements of the power system
%
% inputs:
%   t  -> time in seconds
%   x  -> [delta omega_pu Pm] for each machine
%   y  -> [theta]
%   ps -> power system structure
%
% outputs: 
%   f(1) -> ddelta_dt
%   f(2) -> domega_dt
%   f(3) -> dPm_dt

% constants
C     = psconstants;
nmacs = size(ps.mac,1);
n     = size(ps.bus,1);
ix    = get_indices(n,nmacs);

% extract data from ps
Xd = ps.mac(:,C.ma.Xd);
%Xq = ps.mac(:,C.ma.Xq);
D  = ps.mac(:,C.ma.D);
M  = ps.mac(:,C.ma.M);
omega_0 = 2*pi*ps.frequency;

% extract differential variables
delta    = x(ix.x.delta);
omega_pu = x(ix.x.omega_pu);
Pm       = x(ix.x.Pm);

% extract algebraic variables
mac_buses = ps.mac(:,1);
mac_bus_i = ps.bus_i(mac_buses);
theta     = y(ix.y.theta);
theta_mac = theta(mac_bus_i);
delta_m   = delta - theta_mac;

% calculate the electrical power for the generators 
Pg = delta_m./Xd;

% build the output
f = zeros(ix.nf,1);
f(ix.f.delta_dot) = omega_0.*(omega_pu-1);
f(ix.f.omega_dot) = (Pm - Pg - D.*(omega_pu-1))./M;

%DEBUG
%t
%disp([Pm Pg  D.*(omega_pu-1) M delta theta_mac delta_m])

f(ix.f.Pm_dot)    = 0; % FIXME, this should be adjusted to do droop control

% output df_dx if requested
if nargout>1
    % compute the values
    dPg_ddelta = 1./Xd;
    dFswing_ddelta_values = -dPg_ddelta./M;
    dFswing_domega_values = -D./M;
    dFswing_dPm_values    =  1./M;
    % build df_dx
    df_dx = sparse(ix.nx,ix.nx);
    % dFswing_ddelta
    df_dx = df_dx + sparse(ix.f.swing,ix.x.delta,dFswing_ddelta_values,ix.nx,ix.nx);
    % dFswing_domega
    df_dx = df_dx + sparse(ix.f.swing,ix.x.omega_pu,dFswing_domega_values,ix.nx,ix.nx);
    % dFswing_dPm
    df_dx = df_dx + sparse(ix.f.swing,ix.x.Pm,dFswing_dPm_values,ix.nx,ix.nx);
    % dFdelta_dot_domega
    df_dx = df_dx + sparse(ix.f.delta_dot,ix.x.omega_pu,omega_0,ix.nx,ix.nx);
end
% output df_xy if requested
if nargout>2
    % build df_dy (change in f wrt the algebraic variables)
    dPg_dtheta = -dPg_ddelta;
    % assemble df_dy
    cols = ix.y.theta(mac_bus_i);
    df_dy = sparse(ix.f.swing,cols,-dPg_dtheta./M,ix.nx,ix.ny);
end
