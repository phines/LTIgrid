function dfg_dxy = dae_jacobian(t,xy,ps)
% compute the Jacobian of the DAE system

% extract some useful data about the system
n  = size(ps.bus,1);
ng = size(ps.gen,1);
% some indices that allow us to keep track of stuff
ix = get_indices(n,ng);
% extract x and y from xy
x = xy(1:ix.nx);
y = xy((1:ix.ny)+ix.nx); 

% compute the jacobian
[~,df_dx,df_dy] = differential_eqs(t,x,y,ps);
[~,dg_dx,dg_dy] = algebraic_eqs(t,x,y,ps);
dfg_dxy = [df_dx df_dy; dg_dx dg_dy;];
