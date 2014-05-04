% clc
% clear all

global Load_spline
global t_span
global delta_Pref
C = psconstants_will;

ps = case9_ps_lk_perm; % get the real one? K SHOULD BE 0.151, CHECK IT
ps = updateps(ps);

%% set up a necessity for ACE
ps.shunt(:,C.sh.P)=[125;86;99]

%% Set up 2 area, 39bus per area case. 

reg                      = 0.05*ones(length(ps.gov(:,1)),1)
%reg_gen34                = 0
%reg(4)                   = reg_gen34
%reg(5)=reg_gen34
ps.gov(:,C.gov.R)        = ps.gen(:,C.ge.Pmax).*reg/ps.baseMVA % reg constant is 5% of Pmax p.u. instead of 5% of value multiplied by
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

%check to see if slower ramp rates are needed
gen_type    = ps.gen(:,C.ge.type);
gen_type(4) = 3;
ps       = set_ramp_rates(ps);


%% form the load
[Load_spline,ps] = Load_Type_base_cases(8,ps,2*day_in_s,bus_areas);
total_load       = ppval(Load_spline,0:fivemin_in_s:2*day_in_s-fivemin_in_s);  %subtract because don't need load at final moment
ps               = get_ps_areas_libby(ps,bus_areas,load_buses,total_load,0.006);
ps.shunt(:,C.sh.P) = total_load(:,1);


%% Run time horizon sim
%k=[0.0001,0.0002,0.0005,0.001,0.002,0.005,0.01,0.02,0.05,0.1,0.2];
k=[0.01,0.02,0.05,0.1,0.2];
k=[0.05];

for j=1:length(k)
    k(j)
    ps        = get_ps_areas_libby(ps,bus_areas,load_buses,total_load,k(j)); %%delete this afer testing
    t_all     = zeros(day_in_s,1);
    theta_all = zeros(day_in_s,nbus);
    delta_all = zeros(day_in_s,nmacs);
    omega_all = zeros(day_in_s,nmacs);
    Pm_all    = zeros(day_in_s,nmacs);
    Pgs_sbs_all   = [];

%     t_all     = zeros(3000,1);
%     theta_all = zeros(3000,nbus);
%     delta_all = zeros(3000,nmacs);
%     omega_all = zeros(3000,nmacs);
%     Pm_all    = zeros(3000,nmacs);
%     
    for i=1:1%day_in_5min
        if mod(i,10)==0
            i
        end
        
        t_range = [1:fivemin_in_s]+fivemin_in_s*(i-1);
        
        if i==1
            % Set up x0/y0 by running one time step of ED to get PGs
            initial_load      = ps.shunt(:,C.sh.P);
            %timestep_check   = [initial_load,initial_load*1.2,initial_load*0.8, initial_load*0.7];
            [Pgs_sbs,Rgs_sbs] = Econ_Dispatch_fn(ps,total_load(:,i:i+day_in_5min-1),perc_reg,5);
            %ps.gen(:,C.ge.Pg) = Pgs_sbs(:,1); %Use first time step's optimized Pg's for dcpf
            ps                = dcpf(ps);
            
            % prepare the machine state variables
            ps.mac = get_mac_state(ps,'linear');
            
        else
            [Pgs_sbs,Rgs_sbs] = Econ_Dispatch_fn(ps,total_load(:,i:i+day_in_5min-1),perc_reg,5); %load length should stay the same, always looking same distance into future
            %ps.gen(:,C.ge.Pg) = Pgs_sbs(:,1);
            
        end
        
        
        Pgs_sbs_all = [Pgs_sbs_all,Pgs_sbs(:,1)];
        % Set limits for Diffeq Limiter
        ps.gen(:,C.ge.reg_ramp_up)   = Rgs_sbs(:,1);
        ps.gen(:,C.ge.reg_ramp_down) = -Rgs_sbs(:,1);
        
        
        % Simulate the steady state
        tspan=[t_range(1)-1,t_range(end)];
        [t,theta,delta,omega,Pm,ps] = simgrid_lti_lk_perm(ps,tspan,0,i);

        
        theta_sp = spline(t,theta,t_range);
        delta_sp = spline(t,delta,t_range);
        omega_sp = spline(t,omega,t_range);
        Pm_sp    = spline(t,Pm,t_range);
        
        t_all(t_range)       = t_range;
        theta_all(t_range,:) = theta_sp';
        delta_all(t_range,:) = delta_sp';
        omega_all(t_range,:) = omega_sp';
        Pm_all(t_range,:)    = Pm_sp';
    end
    
    
    %% do some plots
    %close all
    day_in_s=i*300 %GETRIDOFTHIS
    subplot_row = 2;
    subplot_col = 2;
    fontsize = 16;
 %   day_in_s=3000  %for making i=1:10 instead of i=1:day_in5min
    
    figure%(2); clf;
    subplot(subplot_row,subplot_col,1)
    plot(t_all,delta_all,'.','MarkerSize',1);
    axis([tmin day_in_s -Inf Inf])
    set(gca,'FontSize',fontsize)
    xlabel('Time')
    ylabel('Delta')
    %title(['K = ',num2str(ps.areas(1,1))])
    
    
    %figure(2);clf;
    subplot(subplot_row,subplot_col,2)
    plot(t_all,theta_all,'.','MarkerSize',1);
    axis([tmin day_in_s -Inf Inf])
    set(gca,'FontSize',fontsize)
    xlabel('Time')
    ylabel('Theta')
    
    %figure(3);clf
    subplot(subplot_row,subplot_col,3)
    plot(t_all,omega_all,'.','MarkerSize',1);
    axis([tmin day_in_s 365 378])
    set(gca,'FontSize',fontsize)
    xlabel('Time')
    ylabel('Omega')
    %ylim([376.991118428,376.991118433])
    
    %figure(4);clf;
    subplot(subplot_row,subplot_col,4)
    plot(t_all,Pm_all.*ps.baseMVA)%,'.','MarkerSize',1);
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
    
    figure;%(4);clf;
    %subplot(subplot_row,subplot_col,5)
    plot(t_all, ppval(Load_spline(1),t_all),'k.','MarkerSize',1)
    axis([tmin day_in_s -Inf Inf])
    set(gca,'FontSize',fontsize)
    
    xlabel('Time')
    ylabel('Load')
    
    
%     %% from will
%     % Check standards
%     disp('Testing NERC Standards')
%     epsilon_1 = 11.6e-3;
%     [ACE,CPS1_scores,CPS2_scores,CPS1,CPS2] = checkStandards_will(ps,omega_all,theta_all,t_all,epsilon_1);
%     
%   
end

%%

