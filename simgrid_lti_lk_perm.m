function [t,theta,delta,omega,Pm,ps] = simgrid_lti_lk_perm(ps,tspan,check_stab)
% NOTE THAT THIS FUNCTION IS NOT WORKING YET...
EPS = 1e-6;

% prep work and data extraction
nmacs = size(ps.mac,1); % get the number of machines
n = size(ps.bus,1); % the number of buses
ix = get_indices_will(n,nmacs); % index to help us find stuff
omega_0 = 2*pi*60; % normal machine speeds
C = psconstants_will;

[x0,y0] = get_xy_will(ps); % get the state of everything at the current operating point


% check to see if x/y are a valid operating point - SHOULD WE LEAVE THIS IN
% OR GET RID OF IT SINCE IT ALTERS THE CURRENT POINT
% [g,~,dg_dy] = algebraic_eqs_lk_perm(0,x0,y0,ps);
% 
% count = 0;
% while any(abs(g)>EPS)
%     count = count+1;
%     dy = - (dg_dy \ g);
%     y0 = y0 + dy;
%     [g,~,dg_dy] = algebraic_eqs_lk_perm(0,x0,y0,ps);
%     if count>10
%         error('Something funny happened');
%     end
% end
xy0 = [x0;y0];



% set up the differential equations
fg = @(t,xy) differential_algebraic_eqs_lk_perm(t,xy,ps);
dfg_dxy = @(t,xy) dae_jacobian_lk_perm(t,xy,ps);

% test the differential equations around the current point
%fg0 = fg(0,xy0);


%% Checkpoint
if check_stab
    f_x = @(x)differential_eqs_lk_perm(0,x,y0,ps);
    f_y = @(y)differential_eqs_lk_perm(0,x0,y,ps);
    g_x = @(x)algebraic_eqs_lk_perm(0,x,y0,ps);
    g_y = @(y)algebraic_eqs_lk_perm(0,x0,y,ps);
    [f,df_dx0,df_dy0] = f_y(y0);
    [g,dg_dx0,dg_dy0] = g_x(x0);
    [g,dg_dx0,dg_dy0] = g_y(y0);
    k=ps.areas(1,1)
    [max_real_evals_full,num_pos_evals]=stability_check(df_dx0,df_dy0,dg_dx0,dg_dy0);
    %checkDerivatives(g_y, dg_dy0,y0);
end

%% ODE
% set options for the ODE solver
mass_mat = sparse(1:ix.nx,1:ix.nx,1,ix.nx+ix.ny,ix.nx+ix.ny);
odeopts = odeset('Mass',mass_mat,...
                 'MassSingular','yes',...
                 'MStateDependence','none',...
                 'Jacobian',dfg_dxy);

% solve the ode's
[t,XY] = ode15s(fg,tspan,xy0,odeopts);

% extract the data from XY
X = XY(:,1:ix.nx);
Y = XY(:,(1:ix.ny) + ix.nx);
delta = X(:,ix.x.delta);
omega = X(:,ix.x.omega_pu) * omega_0; 
Pm =    X(:,ix.x.Pm);
theta = Y;

% relative angle
theta_end = theta(end,:)';
delta_end = delta(end,:)';
mac_bus_i = ps.bus_i(ps.mac(:,1));
delta_m = delta_end - theta_end(mac_bus_i);

% save the most recent data to the ps structure.
ps.bus(:,C.bu.Vang) = (theta_end)*180/pi;
ps.mac(:,C.ma.omega) = omega(end,:)';
ps.mac(:,C.ma.Pm) = Pm(end,:)';
ps.mac(:,C.ma.delta_m) = delta_m;

[x_new,y_new] = get_xy_will(ps);
