function [Load_spline,ps] = Net_Load(ps,tmax,bus_areas,wind_perc,geo_div)
%  Load_Type forms a load for trial with sim_grid
%  The input is ofthe form Load_Type(Val,ps,tmax,bus_areas)
%  For Val=1, a constant load profile is created
%  For Val=2, a simple ramp load profile is created
%  For Val=3, a random load profile is created using a "light" mean reverting random walk
%  For Val=4, a random load profile is created using a "strong" mean reverting random walk
%  For Val=5, a sine wave load profile is created


C = psconstants_will;
initial_load     = ps.shunt(:,C.sh.P);
time = 1:tmax;
load 'wind.mat'  %2-second wind data
%% include load!!
wind_days          = randi(length(wind_total),geo_div,1);
wind_turbines_cell = wind_total(wind_days);
wind_turbines      = cell2mat(wind_turbines_cell);
wind_turbines      = reshape(wind_turbines,length(wind_turbines)/geo_div,geo_div);
wind_turbines_sum  = sum(wind_turbines,2);

load_change     = initial_load;
load_set        = repmat(initial_load,1,tmax);
load_points     = load_set';
    
Load_spline     = spline(time,load_points');
    
max_load        = (max(load_points));
max_load_area_1 = sum(max_load(bus_areas==1));
max_load_area_2 = sum(max_load(bus_areas==2));

    %also, (above) make sure the max of a given time is used, not max of
    %individual loads added together
    
ps.areas(:,C.ar.B) = [round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];


end

