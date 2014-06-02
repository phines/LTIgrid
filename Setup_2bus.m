% SETUP 2 BUS
clc
clear all

C = psconstants_will; 
ps = case2_ps; 
ps = updateps(ps);

%% CHOICES
wind_frac   = 0.1; %wind energy as a fraction of generation
disp_t_mins = 5;  %length of dispatch time interval in minutes
perc_reg    = 1;   %available regulation on the system as a percentage of WHAT
wind_buses  = [1,2]; %bus id's of wind turbines on the entire system
num_turb    = length(wind_buses); %number of wind turbines in the entire system


%% fix this section so it's nice
reg                      = 0.05*ones(length(ps.gov(:,1)),1); %set up 5% regulation
ps.gov(:,C.gov.R)        = ps.gen(:,C.ge.Pmax).*reg/ps.baseMVA; % reg constant is 5% of Pmax p.u. instead of 5% of value multiplied by
ps.mac(:,C.ma.Tg)        = ps.gov(:,C.gov.Tg); %match time contants for all machines in various locations
ps.mac(:,C.ma.R)         = ps.gov(:,C.gov.R);  %match regulation constants for all machines in various locations

load_buses      = ps.bus_i(ps.shunt(:,1));      %bus ids for loads
load_bus_areas  = ps.bus(load_buses,C.bu.area); %areas associated with each load bus id
gen_bus_i       = ps.bus_i(ps.gen(:,1));        %bus ids for generators 
gen_areas       = ps.bus(gen_bus_i,C.bu.area);  %areas assocaited with each generator bus id
bus_areas       = ps.bus(:,C.bu.area);          %areas associated with each bus id

%%
ps0      = ps;
nmacs    = size(ps.gen,1); %number of (non-wind?) machines on the entire system
nbus     = size(ps.bus,1); %number of buses on the entire system
ix       = get_indices_will(nbus,nmacs); % index to help us find stuff
ps       = find_areas(ps); %locate tie lines
ps.gen(:,C.ge.gen_type) = [4;4]; % set each of the 2 generators to single cycle natural gas type
ps       = set_ramp_rates(ps); % set ramp rates of each generator based on its fuel type

ps.gov(:,C.gov.LCmax) = ps.gen(:,C.ge.ramp_rate_up); 
ps.gov(:,C.gov.LCmin) = ps.gen(:,C.ge.ramp_rate_down);



%% load
tmin = 0;
day_in_s     = 24*60*60;               %numher of seconds in a ay: 24hrs*60min/hr*60s/min
disp_t_in_s  = disp_t_mins*60;         %number of seconds in our chosen dispatch time interval
day_in_disp_t  = day_in_s/disp_t_in_s; %number of dispatch time intervals in one day

[Load_spline,ps]   = Load_Type_base_cases(8,ps,2*day_in_s,bus_areas);              %set up load - see help for load types
total_load         = ppval(Load_spline,0:2*day_in_s-disp_t_in_s);      %get the load curve over a two day period, subtract because don't need load at final moment, 2days because need a rolling load for economic dispatch
ps                 = get_ps_areas_libby(ps,bus_areas,load_buses,total_load,0.006); %set k (PCdot gain) and B (ACE frequency deviation gain)
ps.shunt(:,C.sh.P) = total_load(load_buses,1);  %give case struceture the initial load set point
total_load_sum     = sum(total_load);   %find the total load on the system for each time point
load_avg           = mean(total_load_sum); %average total load on the system 

figure; %plot the load 
load_t_s = 0:1:2*day_in_s-disp_t_in_s;
total_load_s = ppval(Load_spline,load_t_s);
plot(load_t_s/60/60,total_load_s)
xlim([0, 1200/60/60])
xlabel('time (hours) ')
ylabel('Load Power (MW) ')

%% Wind
load wind.mat  %load 2 second wind data
day_in_2s  = 30*60*24; %number of 2 second increments in 1 day - 30 2second chunks/min*60min/hr*24hr/day
Wind_sbs = zeros(2*day_in_2s,num_turb);
total_wind = zeros(2*day_in_2s,1);

for i = 1:num_turb
    day_i         = randi(52,1); %choose a random day of wind
    curr_wind     = [cell2mat(wind_cur(day_i));cell2mat(wind_cur(day_i+1))]; %take the next 2 days worth of wind data
    Wind_sbs(:,i) = curr_wind; %save the 2 days of wind data
    total_wind    = total_wind+curr_wind; %add the 2days of wind data to previously loaded wind data to calculate the total wind on the system
end

% want avgwind/avgload=wind_perc
wind_avg        = mean(total_wind);  %find the average wind on the system
mult            = load_avg/wind_avg; %find the multiplier which scales wind to load via averages
Wind_sbs_scaled = Wind_sbs*wind_frac*mult; %scale wind data to be a the fraction of load via the scaling multiplier

% %check
% windcheck = sum(Wind_sbs_scaled,2);
% windavg   = mean(windcheck);
% windfrac  = windavg/load_avg;

Wind_all        = zeros(length(Wind_sbs_scaled),nbus);
Wind_all(:,wind_buses) = Wind_sbs_scaled;
t           = 2:2:2*day_in_2s*2; %seconds in steps of 2 (2s 4s etc) in 2 days
Wind_spline = spline(t,Wind_all'); %spline the wind data

figure; % plot scaled wind data
plot(t/60,Wind_sbs_scaled)
xlabel('Time (minutes) ')
ylabel('Wind Power (MW) ')
ylim([0, Inf])


%% Net load
t        = 0:2*day_in_s;
Wind_val = ppval(Wind_spline,t); %get wind values every second for 2 days via spline
Load_val = ppval(Load_spline,t); %get load values every second for 2 days via spline
Net_load        = Load_val-Wind_val;  %find net load of buses with wind
Net_load_spline = spline(t,Net_load); %spline net load

Net_load_A1 = sum(Net_load(bus_areas==1,:),1); %sum the net load in area 1
Net_load_A2 = sum(Net_load(bus_areas==2,:),1); %sum the net load in area 2
figure;hold on; %plot net load for the area
plot(t,Net_load_A1,'b')
plot(t,Net_load_A2,'g')
legend('Net load in area 1','Net load in area 2')


%% Save!
clear('Wind_all','Wind_sbs','Wind_sbs_scaled','Wind_val','Load_val','Net_load','Net_load_A1','Net_load_A2','curr_wind','t') %clear unnecessary variables in orde rto save for run script
save('case2_vars.mat') %save variables for use in run script