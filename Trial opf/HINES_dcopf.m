function [out1,shunt_factor,gen_status,br_status] = dcopf(ps,opt)
% usage: [Pg,shunt_factor,gen_status,branch_status] = dcopf(ps,options)
%  or 
% usage: ps = dcopf(ps,options)
%  ps is a power systems structure
%  options is an options structure returned from psoptions
%
% Solve a dc optimal power flow problem with the following formulation
% max  (Pd.*Cd)'*sf - Cg'*Pg
%      B*theta = P(Pg,Pd.*sf)
% s.t. gs.*Pg_min <= Pg <= gs.*Pg_max
%      0 <= sf <= 1
%      theta_min <= theta <= theta_max
% where:
%  Pd is the pre-opf demand from the shunt matrix
%  Cd is the cost of unserved demand
%  sf is a factor for reducing demand
%  gs is the generator status variable
%  theta is a vector of pseudo phase angles

debug = 0;

% check the inputs
if nargin<2
    opt = psoptions;
end

% collect some system data
C = psconstants;
nBus    = size(ps.bus,1);
nGen    = size(ps.gen,1);
Pd0_0   = ps.shunt(:,C.sh.P)/ps.baseMVA;
Pg0     = ps.gen(:,C.ge.P)/ps.baseMVA;
gen_status = ps.gen(:,C.ge.status);
Pg_min  = gen_status.*ps.gen(:,C.ge.Pmin)/ps.baseMVA;
Pg_max  = gen_status.*ps.gen(:,C.ge.Pmax)/ps.baseMVA;
br_status = ps.branch(:,C.br.status)~=0;
nBranch = sum(br_status);
flow_max = ps.branch(br_status,opt.opf.rate)/ps.baseMVA;
flow_max(flow_max<=0) = Inf;
% indices:
G = ps.bus_i(ps.gen(:,1));
D0 = ps.bus_i(ps.shunt(:,1));
F = ps.bus_i(ps.branch(br_status,C.br.f));
T = ps.bus_i(ps.branch(br_status,C.br.t));
br_x = ps.branch(br_status,C.br.X);
% remove loads that have no real power
sh_subset = Pd0_0>0;
D = D0(sh_subset);
Pd0 = Pd0_0(sh_subset);
nShunt  = length(D);

% initialize the outputs
Pg = Pg0;
shunt_factor = ps.shunt(:,C.sh.factor);
if nargout==1
    out1 = ps;
else
    out1 = Pg;
end

% compute the loss factor
%loss_factor = sum(Pg0)/sum(Pd0);
loss_factor = 1.00;

% build an index into x, the decision vector
ix.Pg    = (1:nGen);
ix.theta = (1:nBus)   + max(ix.Pg);
ix.flow  = (1:nBranch)+ max(ix.theta);
ix.sf    = (1:nShunt) + max(ix.flow);
nx = max(ix.sf);
if opt.opf.generator_commitment
    ix.gs = (1:nGen) + nx;
    nx = max(ix.gs);
end

%% set up x_min, x_max
x_min = zeros(nx,1) - Inf;
x_max = zeros(nx,1) + Inf;
% Pg
if opt.opf.generator_commitment
    x_min(ix.Pg) = 0;
    x_max(ix.Pg) = Pg_max;
else
    x_min(ix.Pg) = Pg_min;
    x_max(ix.Pg) = Pg_max;
end
% theta
x_min(ix.theta) = -Inf;
x_max(ix.theta) = Inf;
% set the ref to zero
ref = find(ps.bus(:,C.bu.type)==C.REF);
% NEED TO CHECK TO MULTIPLE SUBGRAPHS HERE...
x_min(ix.theta(ref)) = 0;
x_max(ix.theta(ref)) = 0;
% debug:
%x_min(ix.theta(3)) = 0;
%x_max(ix.theta(3)) = 0;
% end debug

% flow
x_min(ix.flow) = -flow_max;
x_max(ix.flow) = +flow_max;
% sf
x_min(ix.sf) = 0;
x_max(ix.sf) = 1;
% gen status
if opt.opf.generator_commitment
    x_min(ix.gs) = 0;
    x_max(ix.gs) = 1;
end

%% integer vars
isinteger = false(nx,1);
if opt.opf.generator_commitment
    isinteger(ix.gs) = true;
end
if opt.opf.branch_switching
    isinteger(ix.bs) = true;
end

%% set up the objective
cost = zeros(nx,1);
Pd_cost = ps.shunt(sh_subset,C.sh.value)*ps.baseMVA;
cost(ix.sf) = -abs(Pd0).*Pd_cost;
cost(ix.Pg) = ps.gen(:,C.ge.cost)*ps.baseMVA;
%cost(ix.theta(1)) = 1; % keeps the angles from growing without bound

%% constraints
% line-flow constraints
br_b = -1./br_x;
A_flow = sparse(1:nBranch,ix.theta(T),+br_b,nBranch,nx) + ...
         sparse(1:nBranch,ix.theta(F),-br_b,nBranch,nx) + ...
         sparse(1:nBranch,ix.flow,-1,nBranch,nx);
b_flow = zeros(nBranch,1);

% bus-equality/power-flow balance constraint
A_pf = sparse(F,ix.flow,-1,nBus,nx) + ... % from end line injections
       sparse(T,ix.flow,+1,nBus,nx) + ... % to end line injections
       sparse(G,ix.Pg,1,nBus,nx)    + ... % generator injection
       sparse(D,ix.sf,-Pd0*loss_factor,nBus,nx); % load injection
b_pf = zeros(nBus,1);

% add in the generator commitment constraints if needed
if opt.opf.generator_commitment
    A_gc1 = sparse(1:nGen,ix.Pg,1,nGen,nx) + ...
            sparse(1:nGen,ix.gs,-Pg_min,nGen,nx);
    b_gc1_min = zeros(nGen,1);
    b_gc1_max =  +Inf(nGen,1);
    A_gc2 = sparse(1:nGen,ix.Pg,1,nGen,nx) + ...
            sparse(1:nGen,ix.gs,-Pg_max,nGen,nx);
    b_gc2_min =  -Inf(nGen,1);
    b_gc2_max = zeros(nGen,1);
    A_gc = [A_gc1;A_gc2];
    b_gc_min = [b_gc1_min;b_gc2_min];
    b_gc_max = [b_gc1_max;b_gc2_max];
else
    A_gc = zeros(0,nx);
    b_gc_min = [];
    b_gc_max = [];
end

% merge the constraints
lp_A     = [A_flow;A_pf;A_gc];
lp_b_min = [b_flow;b_pf;b_gc_min];
lp_b_max = [b_flow;b_pf;b_gc_max];

%% attempt to solve the problem
if any(isinteger)
    [x_star,z,success] = solvemilp(cost,x_min,x_max,isinteger,lp_A,lp_b_min,lp_b_max);
else
    [x_star,z,success] = solvelp(cost,x_min,x_max,lp_A,lp_b_min,lp_b_max);
end
keyboard

%% process the results
if success
    % extract the outputs
    Pg    = x_star(ix.Pg);
    theta = x_star(ix.theta);
    flow = x_star(ix.flow);
    shunt_factor = x_star(ix.sf);
    % some computation
    Pd = Pd0 .* shunt_factor;
    Pft = flow * ps.baseMVA;
    
    if opt.opf.generator_commitment
        gen_status = x_star(ix.gs);
    end
    %br_status ...
    
    if nargout==1
        % assign ouptuts into the ps structure.
        ps.bus(:,C.bu.Vang) = theta*180/pi;
        ps.gen(:,C.ge.Pg) = Pg * ps.baseMVA;
        ps.gen(:,C.ge.Qg) = 0;
        ps.branch(br_status,C.br.Pf) = +Pft;
        ps.branch(br_status,C.br.Pt) = -Pft;
        ps.branch(br_status,C.br.Qf) = 0;
        ps.branch(br_status,C.br.Qt) = 0;
        ps.branch(br_status,C.br.Imag_f) = abs(flow);
        ps.branch(br_status,C.br.Imag_t) = abs(flow);
        ps.branch(~br_status,[C.br.Pf:C.br.Qt C.br.Imag_f C.br.Imag_t]) = 0;
        
        ps.shunt(sh_subset,C.sh.factor) = shunt_factor;
        out1 = ps;
    else
        out1 = Pg*ps.baseMVA; % need to convert to basemva
    end
else
    warning('Could not find a solution to the DC-OPF problem');
end

%% debug
% check a dc load flow solution
if debug
    n = nBus;
    % look at the flows
    ratio = abs(flow)./flow_max;
    hist(ratio,50);
    axis tight
    % find the reference bus/gen
    ref     = find(ps.bus(:,C.bu.type) == C.REF);
    if length(ref)~=1
        error('problem finding reference bus/gen');
    end
    %
    Pbus_g = sparse(G,1,Pg,nBus,1);
    Pbus_d = sparse(D,1,Pd,nBus,1);
    Pbus   = Pbus_g - Pbus_d;
    % calculate B
    b_FT = -1./br_x;
    B = sparse(F,T,-b_FT,n,n) + ...          %Goodarz  B=[-sum(y_ij) Y-ij
        sparse(T,F,-b_FT,n,n) + ...          %Goodarz    Y_ij        -sum(y_ij)]
        sparse(T,T,+b_FT,n,n) + ...
        sparse(F,F,+b_FT,n,n);
    mis = B*theta - Pbus;
    % temp
    G = ps.bus_i(ps.gen(:,1));    % generator locations
    D = ps.bus_i(ps.shunt(:,1));  % demand/shunt locations
    Pg_pu = ps.gen(:,C.ge.P).*ps.gen(:,C.ge.status) / ps.baseMVA;
    Pd_pu = ps.shunt(:,C.sh.P) / ps.baseMVA;
    Pg_full = full(sparse(G,1,Pg_pu,n,1));
    sf = ps.shunt(:,C.sh.factor); % shunt factor, used for load shedding
    Pd_full = full(sparse(D,1,Pd_pu.*sf,n,1));
    net_gen = Pg_full - Pd_full;
    if any(abs(mis)>1e-9)
        error('DCOPF did not come with a valid solution');
    end
    theta_FT = theta(F) - theta(T);
    flow_ = b_FT.*theta_FT;
    if any(abs(flow - flow_)>1e-9)
        flow - flow_
        error('DCOPF did not come with a valid solution');
    end
    Pg_cost    = cost(ix.Pg)'*Pg/ps.baseMVA;
    total_cost = cost'*x_star;
    fprintf('Generator dispatch cost is $%.2f, $%.2f per MWh\n',Pg_cost,Pg_cost/sum(Pg));
    fprintf('Load shedding cost is %.2f\n',sum((Pd0-Pd).*Pd_cost));
    fprintf('Total load shed is %.2f\n',sum(Pd0 - Pd));
end
