function [ACE] = get_ACE(x,y,ps)
% usage: ACE = get_ACE(x,y,ps)

% constants
C     = psconstants_will;
nmacs = size(ps.mac,1);
n     = size(ps.bus,1);

% extract data from ps
br_status  = ps.branch(:,C.br.status)~=0;
br_x       = ps.branch(br_status,C.br.X);
M          = ps.mac(:,C.ma.M);
B          = ps.areas(:,2);
nA         = length(ps.tie_lines_F);
ix         = get_indices(n,nmacs);

% figure out which area each generator is in
gen_bus_i = ps.bus_i(ps.gen(:,1));
gen_areas = ps.bus(gen_bus_i,C.bu.area);

% setup outputs
mean_omega = zeros(nA,1);
ACE        = zeros(nA,1);

% extract differential variables
omega_pu    = x(ix.x.omega_pu);
delta_omega = (omega_pu - 1);

% extract algebraic variables
theta = y(ix.y.theta);

% get bus locations for tie lines in each area
Ptie = zeros(nA,1);
for i = 1:nA
    % first deal with the tie lines going out
    tie_lines_from = ps.tie_lines_F{i}(:);
    if isempty(tie_lines_from)
        flow_out = 0;
    else
        F = ps.bus_i(ps.branch(tie_lines_from,1));
        T = ps.bus_i(ps.branch(tie_lines_from,2));
        flow_out = (theta(F) -theta(T)) ./ br_x(tie_lines_from);
    end
    
    % then get the flow on the time lines out
    tie_lines_to = ps.tie_lines_T{i}(:);
    if isempty(tie_lines_to)
        flow_in = 0;
    else
        F = ps.bus_i(ps.branch(tie_lines_to,1));
        T = ps.bus_i(ps.branch(tie_lines_to,2));
        flow_in = (theta(F) - theta(T)) ./ br_x(tie_lines_to);
    end
    Ptie(i) = (sum(flow_out) - sum(flow_in));
    % find the mean frequency deviation
    gen_subset = (gen_areas==i);
    d_omega_subset = delta_omega(gen_subset);
    M_subset = M(gen_subset);
    mean_omega(i) = (sum(M_subset.*d_omega_subset)/sum(M_subset));
    % calculate ace measurement for each generator
    ACE(i) = (B(i)*mean_omega(i) + Ptie(i)); % add scheduled flow to this...
end
