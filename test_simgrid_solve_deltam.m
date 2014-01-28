% clc
% clear all

global Load_spline

% load some data

C = psconstants_will;

ps = case9_ps_lk_perm; % get the real one? K SHOULD BE 0.151, CHECK IT
ps = updateps(ps);

ps = case39_ps_will;
ps = replicate_case_parallel_gencost_change(ps,2); %CHANGED 
ps = updateps(ps);
ps.bus(40:end,C.bu.area) = 2;
ps.mac(:,C.ma.Tg)        = ps.gov(:,C.gov.Tg);
ps.mac(:,C.ma.R)         = ps.gov(:,C.gov.R);

load_buses = ps.bus_i(ps.shunt(:,1));
bus_areas  = ps.bus(load_buses,C.bu.area);


%ps = dcpf(ps); % dc power flow
tmin=1;
tmax = tmin+59;
perc_reg = 1;
ps0 = ps;
nmacs = size(ps.gen,1);
n = size(ps.bus,1);
ix = get_indices_will(n,nmacs); % index to help us find stuff
ps = find_areas(ps);
ps = set_ramp_rates(ps);

% Determine Reg. from E.D.
initial_load      = ps.shunt(:,C.sh.P);
%timestep_check    = [initial_load,initial_load*1.2,initial_load*0.8, initial_load*0.7];
[Pgs_sbs]         = Econ_Dispatch_fn(ps,(initial_load),perc_reg); 
ps.gen(:,C.ge.Pg) = Pgs_sbs %Use first time step's optimized Pg's for 
ps                = dcpf(ps)

% prepare the machine state variables
ps.mac = get_mac_state(ps,'linear');


%% Set limits for Diffeq Limiter
% ps.gen(:,C.ge.reg_ramp_up)   = Rgs_sbs; 
% ps.gen(:,C.ge.reg_ramp_down) = -Rgs_sbs;
ps.gov(:,C.gov.LCmax)        = ones(nmacs,1); %include the rest of ps.gov?
ps.gov(:,C.gov.LCmin)        = -ones(nmacs,1);

%% form the load
[Load_spline,ps] = Load_Type(4,ps,tmax);
%%
total_load = ppval(Load_spline,0:tmax);  
ps         = get_ps_areas_libby(ps,bus_areas,load_buses,total_load);

% Debug for delta_m
Xd            = ps.mac(:,C.ma.Xd);
Pg            = ps.gen(:,C.ge.Pg)/ps.baseMVA;
delta_m_corr  = Pg.*Xd;
delta_m_mac   = ps.mac(:,C.ma.delta_m);
[x0,y0]       = get_xy_will(ps); % get the state of everything at the current operating point

G             = ps.bus_i(ps.mac(:,1));
delta_m_other = x0(ix.x.delta)-y0(G)


%% Simulate the steady state
[t,theta,delta,omega,Pm,ps] = simgrid_lti_lk_perm(ps,[tmin,tmax],1);

%% do some plots
subplot_row = 2;
subplot_col = 2;
fontsize = 16;

figure(2); clf;
subplot(subplot_row,subplot_col,1)
plot(t,delta);
axis([tmin tmax -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Delta')


%figure(2);clf;
subplot(subplot_row,subplot_col,2)
plot(t,theta);
axis([tmin tmax -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Theta')

%figure(3);clf
subplot(subplot_row,subplot_col,3)
plot(t,omega);
axis([tmin tmax -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Omega')

%figure(4);clf;
subplot(subplot_row,subplot_col,4)
plot(t,Pm);
axis([tmin tmax -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Pm')

figure(3);clf;
subplot(3,1,1)
plot(t,Pm(:,1))
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Pm')
subplot(3,1,2)
plot(t,Pm(:,2),'g')
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Pm')
subplot(3,1,3)
plot(t,Pm(:,3),'r')
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Pm')

figure(4);clf;
%subplot(subplot_row,subplot_col,5)
plot(t, ppval(Load_spline(1),t),'k')
axis([tmin tmax -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Load')

