clear all; close all;
% load some data
C  = psconstants;
ps = case39_ps; % get the real one?
ps = updateps(ps);
ps = dcpf(ps); % dc power flow
ps.mac = get_mac_state(ps,'linear');
n = size(ps.bus,1);
ng = size(ps.gen,1);
ix = get_indices(n,ng);
[x0,y0] = get_xy(ps);
t = 0;

y_start = zeros(size(y0));

% choose a line to take out
br_out = 20;
% take the branch out
ps.branch(br_out,C.br.status) = 0;
% re-build the B bus matrix and solve for the new theta
ps.B = makeBbus(ps);
% check for islands
[graphs,n_sub] = findSubGraphs(ps.B);
% take out a load
ps.shunt(1,C.sh.status) = 0;

% re-calculate the new y values
g = @(y) algebraic_only(t,x0,y,ps);
%checkDerivatives(g,[],y_start)
y_hat = nrsolve(g,y_start);

xy_0     = [x0;y_hat];

fn_fg = @(t,xy) differential_algebraic_eqs(t,xy,ps);
Jac   = get_jacobian(t,xy_0,ps);
mass_matrix = sparse(1:ix.nf,1:ix.nx,1,ix.nf+ix.ng,ix.nx+ix.ny);
options = odeset(   'Mass',mass_matrix, ...
    'MassSingular','yes', ...
    'Jacobian', Jac, ...
    'Stats','on', ...
    'MStateDependence','none',...
    'NormControl','off');

tic
[t,xy_out] = ode23t(fn_fg,[0 50],xy_0,options);
toc

x_out = xy_out(:,1:ix.nx);
delta = x_out(:,ix.x.delta)';
plot(t,delta);
legend({'Gen 1','Gen 2','Gen 3'});

return
