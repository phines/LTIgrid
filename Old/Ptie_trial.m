clc
clear all
theta = rand(1,13,1)'
C = psconstants_will;
ps = case_3area
ps = updateps(ps);


f         = ps.branch(:,1); %all "from" buses forming branch in case
f_id      = ps.bus_i(f);
t         = ps.branch(:,2); %all "to" buses forming branch in case
t_id      = ps.bus_i(t);
X         = ps.branch(:,C.br.X); %reactance values for each branch
bus_areas = ps.bus(:,C.bu.area); %areas of each bus
f_areas   = bus_areas(f_id); %bus areas of each of the "from" buses
t_areas   = bus_areas(t_id); %bus areas of each of the "to" buses
f_t_X_af_at = [f,t,X,f_areas,t_areas];
area_diff_branch = f_areas ~= t_areas; %branches where the "from" area is not equal to the "to" area, indicating a tie line location
areas     = unique(bus_areas); %area values 
nA        = length(areas); %number of areas
Ptie_area = zeros(nA,1);

for i=1:nA
    area         = areas(i); %current area
    fa_area      = f_areas==area; %which "from" buses are in current area (logical)
    ta_area      = t_areas==area; %which "to" buses are in current area (logical)
    diff_ids_f   = and(fa_area==area_diff_branch,fa_area~=0); %which "from" buses are tie lines and in current area
    diff_ids_t   = and(ta_area==area_diff_branch,ta_area~=0); %which "to" buses are tie lines and in current area
    diff_ids     = or(diff_ids_f,diff_ids_t); 
    nTLa         = sum(diff_ids);
    ids_a        = f_id(diff_ids_f);
    ids_a        = [ids_a;t_id(diff_ids_t)] % from buses, i.e. tie line buses in this area
    X_ties       = X(diff_ids_f); %reactance of tie lines
    X_ties       = [X_ties;X(diff_ids_t)];
    ids_na       = t_id(diff_ids_f);
    ids_na       = [ids_na;f_id(diff_ids_t)]
    X_mat        = sparse(1:nTLa,ids_a,1./X_ties,nTLa,length(bus_areas));
    X_mat        = X_mat + sparse(1:nTLa,ids_na,-1./X_ties,nTLa,length(bus_areas));
    mat1         = ones(1,nTLa);
    Ptie_area(i) = mat1*X_mat*theta
%     X_mat          = sparse(ids_a,ids_na,-1./X_ties,length(bus_areas),length(bus_areas)); 
%     X_mat          = sumX_mat+sparse(ids_na,ids_a,1./X_ties,length(bus_areas),length(bus_areas));
%     mat1           = ones(1,length(bus_areas));
%     Ptie1(i)        = mat1*X_mat*theta;
    
end