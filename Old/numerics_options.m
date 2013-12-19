function opts = numerics_options

% nrsolve options
opts.nr.max_iterations = 20;
opts.nr.tolerance = 1e-9;
opts.nr.alpha_min = 0; % the minimum step size for the newton step
opts.nr.mu = 0; % the parameter for the armijo condition
opts.nr.verbose = 1;
opts.nr.linesearch = 'backtrack';
% the following invalidates all of the above
opts.nr.use_fsolve = false;
