clc
clear all
ps = case9_ps_lk_perm; % get the real one? K SHOULD BE 0.151, CHECK IT
ps = updateps(ps);
nmacs = size(ps.mac,1);
n     = size(ps.bus,1);
ix    = get_indices_will(n,nmacs);
C           = psconstants_will;
f           = ps.branch(:,1); %all "from" buses forming branch in case
f_id        = ps.bus_i(f); %bus ids of all "from" buses
t           = ps.branch(:,2); %all "to" buses forming branch in case
t_id        = ps.bus_i(t); %bus ids of all "to" buses
X           = ps.branch(:,C.br.X); %reactance values for each branch
bus_areas   = ps.bus(:,C.bu.area); %areas of each bus
f_areas     = bus_areas(f_id); %bus areas of each of the "from" buses
t_areas     = bus_areas(t_id); %bus areas of each of the "to" buses
areas       = unique(bus_areas); %area values 
nA          = length(areas); %number of areas
[gen_locs,load_locs] = get_locs(ps);
area_diff_branch = f_areas ~= t_areas; %branches where the "from" area is not equal to the "to" area, indicating a tie line location
gen_buses = ps.gen(:,C.ge.bus);
gen_areas = bus_areas(gen_locs==1);
k = ps.areas(:,C.ar.K);

dPcdotdy = zeros(12,9);
dPcdotdy = sparse(dPcdotdy)

for i=1:nA

    area         = areas(i); %current area
    fa_area      = f_areas==area; %which "from" buses are in current area (logical)
    ta_area      = t_areas==area; %which "to" buses are in current area (logical)
    diff_ids_f   = and(fa_area==area_diff_branch,fa_area~=0); %which "from" buses are tie lines and in current area
    diff_ids_t   = and(ta_area==area_diff_branch,ta_area~=0); %which "to" buses are tie lines and in current area    
    ids_a        = f_id(diff_ids_f);
    ids_a        = [ids_a;t_id(diff_ids_t)]; % from buses, i.e. tie line buses in this area
    X_ties       = X(diff_ids_f); %reactance of tie lines
    X_ties       = [X_ties;X(diff_ids_t)];
    ids_na       = t_id(diff_ids_f);
    ids_na       = [ids_na;f_id(diff_ids_t)];
    k_a          = k(i);
    nmacs_a      = sum(gen_areas==i)
    rows         = ix.f.Pc_dot(gen_areas==i);
    for j=1:length(rows)
        dPcdotdy        = dPcdotdy+sparse(rows(j),ids_a,-k_a./X_ties,ix.nf,ix.ny);
        dPcdotdy        = dPcdotdy+sparse(rows(j),ids_na,k_a./X_ties,ix.nf,ix.ny)
    end

    
%     X_mat        = sparse(1:nTLa,ids_a,1./X_ties,nTLa,length(bus_areas));
%     X_mat        = X_mat + sparse(1:nTLa,ids_na,-1./X_ties,nTLa,length(bus_areas));
%     mat1         = ones(1,nTLa);
%     Ptie_area(i) = mat1*X_mat*theta;
  
end