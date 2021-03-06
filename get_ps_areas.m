function [ps] = get_ps_areas(ps,bus_areas,load_buses,total_load)

K = [0.015;0.015]; %governor ramp rate based on ACE - gain constant for each area
demand_area_1 = sum(total_load(load_buses(bus_areas==1),:));
demand_area_2 = sum(total_load(load_buses(bus_areas==2),:));
B = [round(max(demand_area_1)*0.01*10);round(max(demand_area_2)*0.01*10)];%% look at thesis for how to calculate
ps.areas = [K B];


%% see figure 3.4, will's thesis
