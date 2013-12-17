function opt = psoptions(opt)
% some options for the power system simulator files

if nargin==0
    opt = struct;
end

%% power flow options
opt.pf.tolerance = 1e-8; % convergence tolerance
opt.pf.max_iters = 20; % max power flow iterations
opt.pf.CalcIslands = 1; % iteratively calculates each island in runPowerFlow
opt.pf.CascadingPowerFlow = 0;
opt.pf.flat_start = 0;
opt.pf.load_shed_rate = 0.25; % the rate at which under frequency load shedding is done in CascadingPowerFlow mode
opt.pf.linesearch = 'backtrack';
opt.pf.update = true;

%% optimal power flow options
opt.opf.generator_commitment = 0; % switch generators on/off using MIP
opt.opf.branch_switching = 0;     % switch branches on/off using MIP

%% other options
opt.verbose = 1;
opt.seecascade = 1;

%% time-domain simulation options options
opt.sim.ramp_frac = 0.05; % fraction of generator allowed to ramp between generations
opt.sim.writelog  = false;
opt.sim.dt_default = 10; % default (max) time step size
opt.sim.draw = true;
opt.sim.overload_time_limit = 10*60; % number of seconds that the branch can sit at its rateC level (PSS/E manual)
% legacy
opt.simdc = opt.sim;

% 

