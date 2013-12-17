function [fg,dfg_dxy] = differential_algebraic_eqs(t,xy,ps,opt)
% this is the main set of DAEs that define out problem
% usage: [fg,dfg_dxy] = differential_algebraic_eqs(t,xy,ps)

if nargin<4
    opt=[];
end

% extract some useful data about the system
n  = size(ps.bus,1);
ng = size(ps.gen,1);
% some indices that allow us to keep track of stuff
ix = get_indices_will(n,ng);
% extract x and y from xy
x = xy(1:ix.nx);
y = xy((1:ix.ny)+ix.nx); 

% calculate the derivatives if needed:
if nargin==1 % just calculate the values
    f = differential_eqs_lk_perm(t,x,y,ps,opt);
    g = algebraic_eqs_lk_perm(t,x,y,ps,opt);
    fg = [f;g];
else % calculate the values and the derivatives
    [f,df_dx,df_dy] = differential_eqs_lk_perm(t,x,y,ps,opt);
    [g,dg_dx,dg_dy] = algebraic_eqs_lk_perm(t,x,y,ps,opt);
    fg = [f;g];
    dfg_dxy = [df_dx df_dy;
               dg_dx dg_dy;];
end
