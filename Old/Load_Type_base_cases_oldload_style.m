function [Load_spline,ps] = Load_Type_base_cases(Val,ps,tmax,bus_areas)
%  Load_Type forms a load for trial with sim_grid
%  The input is ofthe form Load_Type(Val,ps,tmax,bus_areas)
%  For Val=1, a constant load profile is created
%  For Val=2, a simple up ramp load profile is created
%  For Val=2.1, a simple down ramp load profile is created
%  For Val=3, a random load profile is created using a "light" mean reverting random walk
%  For Val=4, a random load profile is created using a "strong" mean reverting random walk
%  For Val=5, a sine wave load profile is created
% 


C = psconstants_will;
initial_load     = ps.shunt(:,C.sh.P);
time = 1:tmax;
n_bus = length(ps.bus(:,1));
load_allbuses = zeros(n_bus,tmax);
load_buses      = ps.bus_i(ps.shunt(:,1));

if Val == 1
    load            = repmat(initial_load,1,tmax);
    load_points     = load';
    
    max_load = (max(load'));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    %also, (above) make sure the max of a given time is used, not max of
    %individual loads added together
    ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];
    
    
elseif Val == 2
    timesteps = length(time)
    loadmin = initial_load*0.8;
    loadmax = initial_load*1.2;

    loadup  = linspacem(loadmin,loadmax,timesteps/4);
    loaddown = linspacem(loadmax,loadmin,timesteps/4);
    %load  = [loadup,loaddown,loadup,loaddown];
    max_load = loadup(:,end);
    load_steady = repmat(max_load,1,timesteps*0.75);
    load   = [loadup,load_steady];
    load_points     = load';
    
    max_load = (max(load'));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    
    
elseif Val == 2.1
    timesteps = length(time)
    loadmin = initial_load*0.8;
    loadmax = initial_load*1.2;

    loadup  = linspacem(loadmin,loadmax,timesteps/4);
    loaddown = linspacem(loadmax,loadmin,timesteps/4);
    %load  = [loadup,loaddown,loadup,loaddown];
    min_load = loaddown(:,end);
    load_steady = repmat(min_load,1,timesteps*0.75);
    load   = [loaddown,load_steady];
    load_points     = load';
    
    max_load = (max(load'));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    
    
elseif Val == 2.3
    timesteps = length(time)
    loadmin = initial_load*0.2;
    loadmax = initial_load*5;

    loadup  = linspacem(loadmin,loadmax,timesteps/4);
    loaddown = linspacem(loadmax,loadmin,timesteps/4);
    %load  = [loadup,loaddown,loadup,loaddown];
    max_load = loadup(:,end);
    load_steady = repmat(max_load,1,timesteps*0.75);
    load   = [loadup,load_steady];
    load_points     = load';
    
    max_load = (max(load'));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    
    
elseif Val == 3
    load_points  = zeros(tmax,length(initial_load));
    var_light    = zeros(length(initial_load),1);
    std_light    = zeros(length(initial_load),1);

    for i=1:length(initial_load)
       lp = mrrw(tmax,.01,10,1,1);
       load_points(:,i)  = lp*(initial_load(i)/10); %hardcoded for ten in mrrw to be same value we divide by
       var_light(i)      = var(load_points(:,i));
       std_light(i)      = std(load_points(:,i));
    end
    
    
elseif Val == 4
    load_points = zeros(tmax,length(initial_load));
    var_strong  = zeros(length(initial_load),1);
    std_strong  = zeros(length(initial_load),1);
 
    for i=1:length(initial_load)
       lp = mrrw(tmax,.02,10,2,1.5);
       load_points(:,i)  = lp*(initial_load(i)/10); %hardcoded for ten in mrrw to be same value we divide by
       var_strong(i)     = var(load_points(:,i));
       std_strong(i)     = std(load_points(:,i));
    end
    
    
elseif Val == 5
    load_change     = initial_load;
    load_shape      = sin(0.000074*time);
    load            = load_change/5*load_shape;
    for i=1:length(initial_load)
        load(i,:)=load(i,:)+initial_load(i);
    end
    load_points     = load';
    
    max_load = (max(load'));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    %also, (above) make sure the max of a given time is used, not max of
    %individual loads added together
    ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];
elseif Val == 5.1
      load_change     = initial_load;
    load_shape      = sin(0.0064*time);
    load            = load_change/5*load_shape;
    for i=1:length(initial_load)
        load(i,:)=load(i,:)+initial_load(i);
    end
    load_points     = load';
    
    max_load = (max(load'));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    %also, (above) make sure the max of a given time is used, not max of
    %individual loads added together
    ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];
    
    
% elseif Val==6
%     NE_data   = importdata('ISO-NewEngland 5 Minute Total Load.csv');
%     NE_data   = NE_data.data;
%     load_year   = NE_data(:,1);
%     load_month  = NE_data(:,2);
%     load_day    = NE_data(:,3);
%     load_hour   = NE_data(:,4);
%     load_minute = NE_data(:,5);
%     load_second = NE_data(:,6);
%     load_power  = NE_data(:,7);
%     randmonth   = randi(12);
%     randday     = randi(26);
%     Day_begin   = datenum(2005,randmonth,randday,0,0,0);
%     Day_end     = datenum(2005,randmonth,randday+2,0,0,0)
%     
%     load_timestamps  = datenum(load_year,load_month,load_day,load_hour,load_minute,load_second);
%     Day_begin_ind    = find(load_timestamps>=Day_begin,1)
%     Day_end_ind      = find(load_timestamps>=Day_end,1)
%     load_1_day_time  = load_timestamps(Day_begin_ind:Day_end_ind-1)
%     load_1_day_power = load_power(Day_begin_ind:Day_end_ind-1)     
%     load_1_day_time_norm  = load_1_day_time-load_1_day_time(1); %unit is day
%     load_1_day_time_sec   = load_1_day_time_norm*24*60*60;
%     Load_spline = spline(load_1_day_time_sec,load_1_day_power);


elseif Val==7
    load_change     = initial_load;
    load            = repmat(initial_load,1,tmax);
    load_points     = load';
    tenpercinc     = initial_load(1)*2;
    rampup          = initial_load(1):5:tenpercinc;
    flat            = tenpercinc*ones(length(tenpercinc),1);
    rampdown        = tenpercinc:-1:initial_load(1);
    change          = [rampup];%,flat,rampdown]';
    load_points(10:9+length(change),1)  = change;
    load_points(10+length(change):end,1)=max(change);
    
    max_load = (max(load'));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    %also, (above) make sure the max of a given time is used, not max of
    %individual loads added together
    ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];
    
    
elseif Val==8
    load_change     = initial_load;
    load            = repmat(initial_load,1,tmax);
    load_points     = load';
    change_step     = initial_load(1)*1.06;
    change          = initial_load(1)*1.06;
    load_points(30,1)  = change_step;
    load_points(31:end,1)  = change;
    
    max_load = (max(load'));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    %also, (above) make sure the max of a given time is used, not max of
    %individual loads added together
    ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];
   
end


Load_spline = spline(time,load_points');


end

