function [dFPc_domega_values,dFPc_domega_cols, dFPc_domega_rows] = get_dFPc_domega_will(ps)
% usage: [dFPc_domega,ix_omega_weighted Pc_dot_weighted] = get_dFPc_domega(ps)

% constants
C     = psconstants_will;
nmacs = size(ps.mac,1);
n     = size(ps.bus,1);

% extract data from ps
M  = ps.mac(:,C.ma.M); % machine inertia
B  = ps.areas(:,2);    % frequency bias
K  = ps.areas(:,1);    % generator participation factor
nA = length(ps.tie_lines_F); % number of areas
ix  = get_indices_will(n,nmacs); % some indices to keep track of stuff

% figure out which area each generator is in
gen_bus_i = ps.bus_i(ps.gen(:,1));
gen_areas = ps.bus(gen_bus_i,C.bu.area); % indicates which area each generator is in

% figure out how many machines are in each area, and setup outputs
nmacs_area = zeros(nA,1);
nvals = 0;
for a = 1:nA
    gen_subset    = (gen_areas==a); % find the generators in this area
    nmacs_area(a) = sum(gen_subset); % figure out how many gens here
    nvals = nvals + nmacs_area(a).^2;
end
% setup outputs
dFPc_domega_values = zeros(nvals,1);
dFPc_domega_rows   = zeros(nvals,1);
dFPc_domega_cols   = zeros(nvals,1);

% calculate differential valus and jacobian locations
for i = 1:nA
    gen_subset = (gen_areas==i); % find the generators in this area
    nmacs_area = sum(gen_subset); % figure out how many gens here
    M_area = M(gen_subset); % machine inertia constants for this area
    mac_weights = M_area/sum(M_area);
    K_area = K(i); % generator participation factors for area
    B_area = B(i); % frequency bias for area i
    dPc_ddelta_omega = -K_area*B_area;
    domega_ddelta_omega = mac_weights;
%     dHz_domega_pu = ps.frequency;
%     dPc_pu_dPc_MW = 1/ps.baseMVA;
%     dFPc_domega = dPc_ddelta_omega*domega_ddelta_omega*dHz_domega_pu*dPc_pu_dPc_MW;
    dFPc_domega = dPc_ddelta_omega*domega_ddelta_omega;
    omega_cols = ix.x.omega_pu(gen_subset);
    Pc_rows    = ix.x.delta_Pc(gen_subset);
    for k = 1:nmacs_area
        ix_nvals = (1:nmacs_area) + nmacs_area*(k-1) + sum(gen_subset).^2*(i-1);
        dFPc_domega_values(ix_nvals) = dFPc_domega;
        dFPc_domega_rows(ix_nvals)   = Pc_rows;
        dFPc_domega_cols(ix_nvals)   = omega_cols;
    end
end
dFPc_domega_rows = sort(dFPc_domega_rows);
