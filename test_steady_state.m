clear all; close all;
% load some data
ps = case9_ps; % get the real one?
ps = updateps(ps);
ps = dcpf(ps); % dc power flow
ps.mac = get_mac_state(ps,'linear');
n = size(ps.bus,1);
ng = size(ps.gen,1);
ix = get_indices(n,ng);

[x0,y0] = get_xy(ps);
xy_0 = [x0;y0];
t = 0;

%% test the steady state system
fn_fg = @(t,xy) differential_algebraic_eqs(t,xy,ps);
Jac   = get_jacobian(t,xy_0,ps);
mass_matrix = sparse(1:ix.nf,1:ix.nx,1,ix.nf+ix.ng,ix.nx+ix.ny);
options = odeset(   'Mass',mass_matrix, ...
                    'MassSingular','yes', ...
                    'Jacobian', @(t,xy)get_jacobian(t,xy,ps), ...
                    'Stats','on', ... 
                    'MStateDependence','none',...
                    'NormControl','off');

tic
[t,xy_out] = ode23t(fn_fg,[0 500],xy_0,options);
toc

%% plot something
x_out = xy_out(:,(1:ix.nx));
y_out = xy_out(:,(1:ix.ny)+ix.nx);

delta = x_out(:,ix.x.delta);
figure(1); clf;
plot(t,delta');
xlabel('Time (seconds)');
ylabel('Machine angles (radians)');

