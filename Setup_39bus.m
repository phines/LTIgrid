% SETUP 39 BUS
clc
clear all

C = psconstants_will;

ps = case39_ps_will;
ps = replicate_case_parallel_gencost_change(ps,2); %CHANGED 
ps = updateps(ps);
ps.bus(40:end,C.bu.area) = 2;
reg                      = 0.05*ones(length(ps.gov(:,1)),1);
ps.gov(:,C.gov.R)        = ps.gen(:,C.ge.Pmax).*reg/ps.baseMVA; % reg constant is 5% of Pmax p.u. instead of 5% of value multiplied by
ps.mac(:,C.ma.Tg)        = ps.gov(:,C.gov.Tg);
ps.mac(:,C.ma.R)         = ps.gov(:,C.gov.R);


%% CHOICES - CHECK
wind_frac   = 0.1;
disp_t_mins = 5;  %minute length of dispatch time interval
perc_reg    = 1;
wind_buses  = [105 109 114 117 205 209 214 217];
wind_buses  = ps.bus_i(wind_buses');
num_turb    = length(wind_buses);

load_buses      = ps.bus_i(ps.shunt(:,1));
load_bus_areas  = ps.bus(load_buses,C.bu.area);
gen_bus_i       = ps.bus_i(ps.gen(:,1));
gen_areas       = ps.bus(gen_bus_i,C.bu.area);
bus_areas   = ps.bus(:,C.bu.area);


%% Set up long term
tmin = 0;
day_in_s     = 24*60*60; %24hrs*60min/hr*60s/min
disp_t_in_s  = disp_t_mins*60;
day_in_disp_t  = day_in_s/disp_t_in_s; %number of ED time periods in one day

ps0      = ps;
nmacs    = size(ps.gen,1);
nbus     = size(ps.bus,1);
ix       = get_indices_will(nbus,nmacs); % index to help us find stuff
ps       = find_areas(ps);
ps       = set_ramp_rates(ps);

ps.gov(:,C.gov.LCmax)=ps.gen(:,C.ge.ramp_rate_up);
ps.gov(:,C.gov.LCmin)=ps.gen(:,C.ge.ramp_rate_down);

%% form the load
[Load_spline,ps] = Load_Type_base_cases(8,ps,2*day_in_s,load_bus_areas);
total_load       = ppval(Load_spline,0:disp_t_in_s:2*day_in_s-disp_t_in_s);  %subtract because don't need load at final moment
ps               = get_ps_areas_libby(ps,load_bus_areas,load_buses,total_load,0.006);
ps.shunt(:,C.sh.P) = total_load(load_buses,1);
total_load_sum     = sum(total_load);
load_avg           = mean(total_load_sum);

%% WIND
load wind.mat  %2 second wind data
day_in_2s  = 30*60*24;
Wind_sbs = zeros(2*day_in_2s,num_turb);
total_wind = zeros(2*day_in_2s,1);
for i = 1:num_turb
    day_i         = randi(52,1);
    curr_wind     = [cell2mat(wind_cur(day_i));cell2mat(wind_cur(day_i+1))];
    Wind_sbs(:,i) = curr_wind;
    total_wind    = total_wind+curr_wind;
end

% want avgwind/avgload=wind_perc
wind_avg        = mean(total_wind);
mult            = load_avg/wind_avg;
Wind_sbs_scaled = Wind_sbs*wind_frac*mult;

% %check
% windcheck = sum(Wind_sbs_scaled,2);
% windavg   = mean(windcheck);
% windfrac  = windavg/load_avg;
Wind_all        = zeros(length(Wind_sbs_scaled),nbus);
Wind_all(:,wind_buses) = Wind_sbs_scaled;
t           = 2:2:2*day_in_2s*2; %seconds in steps of 2 (2s 4s etc) in 2 days
Wind_spline = spline(t,Wind_all'); 

figure;
plot(t/60,Wind_sbs_scaled)
xlabel('Time (minutes) ')
ylabel('Wind Power (MW) ')
ylim([0, Inf])


%% Net load
t        = 0:2*day_in_s;
Wind_val = ppval(Wind_spline,t);
Load_val = ppval(Load_spline,t);

Net_load   = Load_val-Wind_val; % find net load of buses with wind
Net_load_spline = spline(t,Net_load); %spline net load


Net_load_A1 = sum(Net_load(bus_areas==1,:));
Net_load_A2 = sum(Net_load(bus_areas==2,:));
figure;hold on;
plot(t,Net_load_A1,'b')
plot(t,Net_load_A2,'g')
legend('Net load in area 1','Net load in area 2')


%% Save!
clear('Wind_all','Wind_sbs','Wind_sbs_scaled','Wind_val','Load_val','Net_load','Net_load_A1','Net_load_A2','curr_wind','t')
save('case39_vars.mat')