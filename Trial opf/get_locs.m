function [genloc loadloc windloc] = get_locs(ps,wind_buses)
%%why not use persistent C here?
m = max(ps.bus(:,1));			   
nodes = ones(m,1);
nodes(ps.bus(:,1)) = 0;
non_nodes = find(nodes);


genloc  = sparse(ps.gen(:,1),1,1,m,1);
loadloc = sparse(ps.shunt(:,1),1,1,m,1);
			   
genloc(non_nodes)  = [];
loadloc(non_nodes) = []; %%why are these necessary? 

if nargin > 1
    windloc = sparse(wind_buses,1,1,m,1);
    windloc(non_nodes) = [];
end