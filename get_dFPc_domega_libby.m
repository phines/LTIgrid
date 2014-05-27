function [dFPc_domega_values,dFPc_domega_cols, dFPc_domega_rows] = get_dFPc_domega_libby(ps,dPcdotlim_dPcdot)
% usage: [dFPc_domega,ix_omega_weighted Pc_dot_weighted] = get_dFPc_domega(ps)

% constants
C     = psconstants_will;
nmacs = size(ps.mac,1);
n     = size(ps.bus,1);

% extract data from ps
B    = ps.areas(:,2);    % frequency bias
K    = ps.areas(:,1);    % generator participation factor
nA   = length(ps.tie_lines_F); % number of areas
ix   = get_indices_will(n,nmacs); % some indices to keep track of stuff
Pmax = ps.gen(:,C.ge.Pmax);

% figure out which area each generator is in
gen_bus_i = ps.bus_i(ps.gen(:,1));
gen_areas = ps.bus(gen_bus_i,C.bu.area); % indicates which area each generator is in

% figure out how many machines are in each area, and setup outputs
nmacs_area = zeros(nA,1);
nvals = 0;
for a = 1:nA
    gen_subset    = (gen_areas==a); % find the generators in this area
    nmacs_area(a) = sum(gen_subset); % figure out how many gens here
    nvals = nvals + nmacs_area(a);%.^2;
end
% setup outputs
dFPc_domega_values = zeros(nvals,1);
dFPc_domega_rows   = [];
dFPc_domega_cols   = [];

% calculate differential values and jacobian locations
spot = 0;
for i = 1:nA
    gen_subset = (gen_areas==i); % find the generators in this area
    nmacs_area = sum(gen_subset); % figure out how many gens here
    lim_scale_a  = dPcdotlim_dPcdot(gen_subset);
    K_area = K(i); % generator participation factors for area
    B_area = B(i); % frequency bias for area i
    dPc_ddelta_omega = -K_area*B_area;
   

%     dHz_domega_pu = ps.frequency;
%     dPc_pu_dPc_MW = 1/ps.baseMVA;
%     dFPc_domega = dPc_ddelta_omega*domega_ddelta_omega*dHz_domega_pu*dPc_pu_dPc_MW;
    dFPc_domega = dPc_ddelta_omega;
    omega_cols = ix.x.omega_pu(gen_subset);
    Pc_rows    = ix.x.delta_Pc(gen_subset);
    [~,Pmax_sub_ind] = max(Pmax(gen_subset));
    for k = 1:nmacs_area
        spot=spot+1;
        dFPc_domega_values(spot) = dFPc_domega*lim_scale_a(Pmax_sub_ind);
    end
   
    omega_cols = repmat(omega_cols(Pmax_sub_ind),1,length(omega_cols));
    dFPc_domega_rows   = vertcat(dFPc_domega_rows,Pc_rows');
    dFPc_domega_cols   = vertcat(dFPc_domega_cols,omega_cols');
    
end
