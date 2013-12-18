function ps = find_areas(ps)
% usage: ps = find_areas(ps)

C = psconstants_will;
area_nos = ps.bus(:,C.bu.area);
F = ps.bus_i(ps.branch(:,1));
T = ps.bus_i(ps.branch(:,2));

a_set = unique(area_nos);
nA = length(a_set);

for i = 1:nA
    a = a_set(i);
    is_in_area = (area_nos==a);
    area_bus_set = find(is_in_area);
    is_tie_line_F = ismember(F,area_bus_set) & ~ismember(T,area_bus_set);
    is_tie_line_T = ismember(T,area_bus_set) & ~ismember(F,area_bus_set);
    ps.tie_lines_T{a} = find(is_tie_line_T);
    ps.tie_lines_F{a} = find(is_tie_line_F);
    ps.bus_tie_locs_T{a} = T(is_tie_line_T);
    ps.bus_tie_locs_F{a} = F(is_tie_line_F);
end

%% finds members of a given area which have a from and not a to (or vice versa) within the area, which is to say that the other location (F or T) is in another area, designating it a tie line.