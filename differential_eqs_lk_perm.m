function [f,df_dx,df_dy] = differential_eqs_lk_10_6(t,x,y,ps,opt)
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
%   f(4) -> dPc_dt

%keyboard
% constants
C     = psconstants_will;
nmacs = size(ps.mac,1);
n     = size(ps.bus,1);
ix    = get_indices_will(n,nmacs);

% extract data from ps
Xd      = ps.mac(:,C.ma.Xd);
%Xq     = ps.mac(:,C.ma.Xq);
D       = ps.mac(:,C.ma.D);
M       = ps.mac(:,C.ma.M);
omega_0 = 2*pi*ps.frequency; %why is this times 2pi if we do everything in pu and dont use 2pi elsewhere
Tg      = ps.mac(:,C.ma.Tg); %unhardcode
R       = ps.mac(:,C.ma.R);%unhardcode
K_ace   = ps.areas(:,C.ar.K);
Pref    = ps.gen(:,2)/ps.baseMVA;%% need to add gen dispatch

% extract differential variables
delta    = x(ix.x.delta);
omega_pu = x(ix.x.omega_pu);
Pm       = x(ix.x.Pm);
delta_Pc = x(ix.x.delta_Pc);


% extract algebraic variables
mac_buses = ps.mac(:,1);
mac_bus_i = ps.bus_i(mac_buses);
theta     = y(ix.y.theta);
theta_mac = theta(mac_bus_i);
delta_m   = delta - theta_mac;

% calculate the electrical power for the generators 
Pg = delta_m./Xd;

% calculate Pmdot values
delta_omega_pu = (omega_pu-1);

% PCdot
ACE = get_ACE_temp(x,y,ps);
Pc_dot = -K_ace.*ACE;

% for each area, put the appropriate Pc_dot with the machines
gen_bus_i = ps.bus_i(ps.gen(:,1));
gen_areas = ps.bus(gen_bus_i,C.bu.area);
Pc_dot = Pc_dot(gen_areas);

% build the output
f = zeros(ix.nf,1);
f(ix.f.delta_dot) = omega_0.*(omega_pu-1);
f(ix.f.omega_dot) = (Pm - Pg - D.*(omega_pu-1))./M;
f(ix.f.Pm_dot)    = (1./Tg).*(Pref + delta_Pc - Pm - delta_omega_pu./R); % FIXME, this should be adjusted to do droop control
f(ix.f.Pc_dot)    = Pc_dot;

%DEBUG
%t
%disp([Pm Pg  D.*(omega_pu-1) M delta theta_mac delta_m])


% output df_dx if requested
if nargout>1
    % compute the values
    dPg_ddelta = 1./Xd;
    dFswing_ddelta_values = -dPg_ddelta./M;
    dFswing_domega_values = -D./M;
    dFswing_dPm_values    =  1./M;
    dFPm_dot_dPc_values   = (1./Tg);
    dFPm_dPm_values       = (-1./Tg);
    dFPm_domega_values    = (-1./R).*(1./Tg);

    [dFPc_domega_values,dFPc_domega_cols,dFPc_domega_rows] = get_dFPc_domega_libby(ps);
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
    % dFPc_domega
    df_dx = df_dx + sparse(dFPc_domega_rows,dFPc_domega_cols,dFPc_domega_values,ix.nx,ix.nx);
    % dFPm_dPc
    df_dx = df_dx + sparse(ix.f.Pm_dot,ix.x.delta_Pc,dFPm_dot_dPc_values,ix.nx,ix.nx);
    % dPm_dPm 
    df_dx = df_dx + sparse(ix.f.Pm_dot,ix.x.Pm,dFPm_dPm_values,ix.nx,ix.nx);
    % dFPm_domega_values
    df_dx = df_dx + sparse(ix.f.Pm_dot,ix.x.omega_pu,dFPm_domega_values,ix.nx,ix.nx);
end
% output df_dy if requested
if nargout>2
    % build df_dy (change in f wrt the algebraic variables)
    dPg_dtheta = -dPg_ddelta;
    % assemble df_dy
    cols = ix.y.theta(mac_bus_i);
    df_dy = sparse(ix.f.swing,cols,-dPg_dtheta./M,ix.nx,ix.ny);
        % dFPc_dtheta
    df_dy = get_dFPc_dtheta_Libby(ps,df_dy);
end
