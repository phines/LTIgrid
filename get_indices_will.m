function index = get_indices_will(n_bus,n_macs)
% usage: index = get_indices(n_bus,n_macs)
% produces a structure that helps us to know where stuff is in x,y,f,g

% differential (generator) variable index
index.x.delta    = (1:n_macs);
index.x.omega_pu = (1:n_macs) + n_macs;
index.x.Pm       = (1:n_macs) + n_macs*2;
index.x.delta_Pc = (1:n_macs) + n_macs*3;
index.nx         = n_macs*4;
index.x.omega    = index.x.omega_pu; % synonym

% differential equation index is the same as x index
index.f.delta_dot = index.x.delta;
index.f.omega_dot = index.x.omega_pu;
index.f.Pm_dot    = index.x.Pm;
index.f.Pc_dot    = index.x.delta_Pc;
index.nf          = index.nx;
index.f.swing     = index.f.omega_dot; % synonym

% algebraic variable index
index.y.theta     = (1:n_bus);
index.ny          = n_bus;

% algebraic function index
index.g.P = (1:n_bus);
index.ng  = n_bus;

return
