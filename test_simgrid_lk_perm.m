% clc
% clear all

global Load_spline
C = psconstants_will;

% ps = case9_ps_lk_perm; % get the real one? K SHOULD BE 0.151, CHECK IT
% ps = updateps(ps);

%% Set up 2 area, 39bus per area case. 
ps = case39_ps_will;
ps = replicate_case_parallel_gencost_change(ps,2); %CHANGED 
ps = updateps(ps);

ps.bus(40:end,C.bu.area) = 2;
ps.gov(:,C.gov.R)        = ps.gen(:,C.ge.Pmax).*0.05/ps.baseMVA % reg constant is 5% of Pmax p.u. instead of 5% of value multiplied by
ps.mac(:,C.ma.Tg)        = ps.gov(:,C.gov.Tg);
ps.mac(:,C.ma.R)         = ps.gov(:,C.gov.R);

load_buses = ps.bus_i(ps.shunt(:,1));
bus_areas  = ps.bus(load_buses,C.bu.area);


%% Set up long term
tmin = 0;
tmax = tmin+59;
day_in_s     = 24*60*60; %24hrs*60min/hr*60s/min
fivemin_in_s = 5*60;
day_in_5min  = day_in_s/fivemin_in_s;

perc_reg = 1;
ps0      = ps;
nmacs    = size(ps.gen,1);
nbus     = size(ps.bus,1);
ix       = get_indices_will(nbus,nmacs); % index to help us find stuff
ps       = find_areas(ps);
ps       = set_ramp_rates(ps);


%% form the load
[Load_spline,ps] = Load_Type(6,ps,2*day_in_s,bus_areas);
total_load       = ppval(Load_spline,0:fivemin_in_s:2*day_in_s-fivemin_in_s);  %subtract because don't need load at final moment
ps               = get_ps_areas_libby(ps,bus_areas,load_buses,total_load); %is this the right total load? (before total load was for 60 seconds)



%% Run time horizon sim
t_all     = zeros(day_in_s,1);
theta_all = zeros(day_in_s,nbus);
delta_all = zeros(day_in_s,nmacs);
omega_all = zeros(day_in_s,nmacs);
Pm_all    = zeros(day_in_s,nmacs);

for i=1:day_in_5min
    if mod(i,10)==0
        i
    end
    
    t_range = [1:fivemin_in_s]+fivemin_in_s*(i-1);
    
    if i==1
        % Set up x0/y0 by running one time step of ED to get PGs
        initial_load      = ps.shunt(:,C.sh.P);
        %timestep_check   = [initial_load,initial_load*1.2,initial_load*0.8, initial_load*0.7];
        [Pgs_sbs,Rgs_sbs] = Econ_Dispatch_fn(ps,total_load(:,i:i+day_in_5min-1),perc_reg); 
        ps.gen(:,C.ge.Pg) = Pgs_sbs(:,1); %Use first time step's optimized Pg's for dcpf
        ps                = dcpf(ps);

        % prepare the machine state variables
        ps.mac = get_mac_state(ps,'linear');
        
    else
        [Pgs_sbs,Rgs_sbs] = Econ_Dispatch_fn(ps,total_load(:,i:i+day_in_5min-1),perc_reg); %load length should stay the same, always looking same distance into future
        ps.gen(:,C.ge.Pg) = Pgs_sbs(:,1);
        
    end


    % Set limits for Diffeq Limiter
    ps.gen(:,C.ge.reg_ramp_up)   = Rgs_sbs(:,1); 
    ps.gen(:,C.ge.reg_ramp_down) = -Rgs_sbs(:,1);
    ps.gov(:,C.gov.LCmax)        = ones(nmacs,1); %include the rest of ps.gov?
    ps.gov(:,C.gov.LCmin)        = -ones(nmacs,1);


    % Simulate the steady state
    [t,theta,delta,omega,Pm,ps] = simgrid_lti_lk_perm(ps,t_range,0);
    
    % Combine data
    t_all(t_range)=t;
    theta_all(t_range,:) =theta;
    delta_all(t_range,:) =delta;
    omega_all(t_range,:) =omega;
    Pm_all(t_range,:)    =Pm;    
end


%% do some plots
subplot_row = 2;
subplot_col = 2;
fontsize = 16;

figure(2); clf;
subplot(subplot_row,subplot_col,1)
plot(t_all,delta_all);
axis([tmin day_in_s -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Delta')
title(['K = ',num2str(ps.areas(1,1))])


%figure(2);clf;
subplot(subplot_row,subplot_col,2)
plot(t_all,theta_all);
axis([tmin day_in_s -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Theta')

%figure(3);clf
subplot(subplot_row,subplot_col,3)
plot(t_all,omega_all);
axis([tmin day_in_s -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Omega')

%figure(4);clf;
subplot(subplot_row,subplot_col,4)
plot(t_all,Pm_all);
axis([tmin day_in_s -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Pm')
% 
% figure(3);clf;
% subplot(3,1,1)
% plot(t,Pm_all(:,1))
% set(gca,'FontSize',fontsize)
% xlabel('Time')
% ylabel('Pm')
% subplot(3,1,2)
% plot(t,Pm(:,2),'g')
% set(gca,'FontSize',fontsize)
% xlabel('Time')
% ylabel('Pm')
% subplot(3,1,3)
% plot(t,Pm(:,3),'r')
% set(gca,'FontSize',fontsize)
% xlabel('Time')
% ylabel('Pm')

figure(4);clf;
%subplot(subplot_row,subplot_col,5)
plot(t_all, ppval(Load_spline(1),t_all),'k')
axis([tmin day_in_s -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Load')

