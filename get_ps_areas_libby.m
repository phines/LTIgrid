function [ps] = get_ps_areas_libby(ps,bus_areas,load_buses,total_load,k)


K = [k;k]; %governor ramp rate based on ACE - gain constant for each area
demand_area_1 = sum(total_load(load_buses(bus_areas==1),:),1);
demand_area_2 = sum(total_load(load_buses(bus_areas==2),:),1);
B = [round(max(demand_area_1)*0.01*10);round(max(demand_area_2)*0.01*10)];%% look at thesis for how to calculate
B_pu = B/ps.baseMVA*ps.frequency; %B=Mw/Hz*60Hz/100MW=puP/pufreq
ps.areas = [K B_pu];

%% see figure 3.4, will's thesis
