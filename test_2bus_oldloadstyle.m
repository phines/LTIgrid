%4/11
clc
clear all

global Load_spline
global Pref_check
global delta_Pref
global t_span
global delta_Pc_lim_check

Pref_check=[];
delta_Pc_lim_check=[];
load case2_vars.mat
C = psconstants_will;
% disp_t_mins = 5;  %minute length of dispatch time interval
% perc_reg = 1;


%% Set up long term
ps0      = ps;
nmacs    = size(ps.gen,1);
nbus     = size(ps.bus,1);
ix       = get_indices_will(nbus,nmacs); % index to help us find stuff


%% Run time horizon sim
%k=[0.0001,0.0002,0.0005,0.001,0.002,0.005,0.01,0.02,0.05,0.1,0.2];
%k=[0.01,0.02,0.05,0.1,0.2];
k = 0.05;

for j=1:length(k)
    ps        = get_ps_areas_libby(ps,bus_areas,load_buses,total_load,k(j)); %%delete this afer testing
    t_all     = zeros(day_in_s,1);
    theta_all = zeros(day_in_s,nbus);
    delta_all = zeros(day_in_s,nmacs);
    omega_all = zeros(day_in_s,nmacs);
    Pm_all    = zeros(day_in_s,nmacs);
    delta_Pc_all    = zeros(day_in_s,nmacs);
    Pgs_sbs_all   = [];

     
    for i=1:4%day_in_disp_t
        if mod(i,10)==0
            disp(i)
        end
        
        t_range = 1:disp_t_in_s+disp_t_in_s*(i-1);
        t_span=[t_range(1)-1,t_range(end)];
        if i==1
            [Pgs_sbs,Rgs_sbs] = Econ_Dispatch_fn(ps,total_load(:,i:i+day_in_disp_t-1),perc_reg,disp_t_mins);
            ps.gen(:,C.ge.Pg) = Pgs_sbs(:,1); %Use first time step's optimized Pg's for dcpf
            ps                = dcpf(ps);
            ps.gen(:,C.ge.Pg) = Pgs_sbs(:,1);%hshould this be here?!
            delta_Pref        = [ps.gen(:,C.ge.Pg),Pgs_sbs(:,2)];
            
            % prepare the machine state variables
            ps.mac = get_mac_state(ps,'linear');
            
        else
            [Pgs_sbs,Rgs_sbs] = Econ_Dispatch_fn(ps,total_load(:,i:i+day_in_disp_t-1),perc_reg,disp_t_mins); %load length should stay the same, always looking same distance into future
            ps.gen(:,C.ge.Pg) = Pgs_sbs(:,1);
            delta_Pref        = [ps.gen(:,C.ge.Pg),Pgs_sbs(:,2)];
            %should next step be set to output of diffeq? are we changing
            %load at all? how should this be done while checking ACE
        end
         
        
        Pgs_sbs_all = [Pgs_sbs_all,Pgs_sbs(:,1)];
        % Set limits for Diffeq Limiter
        ps.gen(:,C.ge.reg_ramp_up)   = Rgs_sbs(:,1);
        ps.gen(:,C.ge.reg_ramp_down) = -Rgs_sbs(:,1);
        
        
        % Simulate the steady state
       
        [t,theta,delta,omega,Pm,delta_Pc,ps] = simgrid_lti_lk_perm(ps,t_span,0,i);

        
        theta_sp = spline(t,theta,t_range);
        delta_sp = spline(t,delta,t_range);
        omega_sp = spline(t,omega,t_range);
        Pm_sp    = spline(t,Pm,t_range);
        delta_Pc_sp    = spline(t,delta_Pc,t_range);
        
        t_all(t_range)       = t_range;
        theta_all(t_range,:) = theta_sp';
        delta_all(t_range,:) = delta_sp';
        omega_all(t_range,:) = omega_sp';
        Pm_all(t_range,:)    = Pm_sp';
        delta_Pc_all(t_range,:)    = delta_Pc_sp';
    end
    
    % Pref check
    [Pref_check] = unique(Pref_check,'rows');
    Pref_t = Pref_check(:,1);
    Pref_1 = Pref_check(:,2);
    Pref_2 = Pref_check(:,3);
    [delta_Pc_lim_check] = unique(delta_Pc_lim_check,'rows');
    delta_Pc_lim_t = delta_Pc_lim_check(:,1);
    delta_Pc_lim_1 = delta_Pc_lim_check(:,2);
    delta_Pc_lim_2 = delta_Pc_lim_check(:,3);
    
    %% do some plots
    %close all
    day_in_s=i*300; %GETRIDOFTHIS
    subplot_row = 2;
    subplot_col = 2;
    fontsize = 16;
 %   day_in_s=3000  %for making i=1:10 instead of i=1:day_in5min
 % Get used all's.
    ids   = find(t_all(t_all~=0));
    t_all = t_all(ids);
    delta_all = delta_all(ids,:);
    theta_all = theta_all(ids,:);
    omega_all = omega_all(ids,:);
    Pm_all = Pm_all(ids,:);
    delta_Pc_all = delta_Pc_all(ids,:);
    t_all_minute = t_all/60;
    
    
    figure%(2); clf;
    subplot(subplot_row,subplot_col,1)
    plot(t_all_minute,delta_all,'.','MarkerSize',1);
    axis([tmin day_in_s/60 min(min(delta_all))-.5 max(max(delta_all))+.5])
    set(gca,'FontSize',fontsize)
    xlabel('Time (minutes) ')
    ylabel('Delta (rads) ')
   % title(['K = ',num2str(ps.areas(1,1))])
    
    
    %figure(2);clf;
    subplot(subplot_row,subplot_col,2)
    plot(t_all_minute,theta_all,'.','MarkerSize',1);
    axis([tmin day_in_s/60 min(min(theta_all))-.5 max(max(theta_all))+.5])
    set(gca,'FontSize',fontsize)
    xlabel('Time (minutes) ')
    ylabel('Theta (rads) ')
    
    %figure(3);clf
    subplot(subplot_row,subplot_col,3)
    plot(t_all_minute,omega_all,'.','MarkerSize',1);
    axis([tmin day_in_s/60 min(min(omega_all))-.1 max(max(omega_all))+.1])
    set(gca,'FontSize',fontsize)
    xlabel('Time (minutes) ')
    ylabel('Omega (rad/s) ')
    %ylim([376.991118428,376.991118433])
    
    %figure(4);clf;
    subplot(subplot_row,subplot_col,4); hold on;
    plot(t_all_minute,Pm_all.*ps.baseMVA,'.','MarkerSize',1);
    plot(Pref_t/60,Pref_1*ps.baseMVA,'m.','MarkerSize',1)
    plot(Pref_t/60,Pref_2*ps.baseMVA,'r.','MarkerSize',1)
    axis([tmin day_in_s/60 min(min(Pm_all.*ps.baseMVA))-.5 max(max(Pm_all.*ps.baseMVA))+.5])
    set(gca,'FontSize',fontsize)
    xlabel('Time (minutes) ')
    ylabel('Pm (MW) ')

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
    plot(t_all_minute, ppval(Load_spline(1),t_all),'k')%.','MarkerSize',1)
    axis([tmin day_in_s/60 min(min(ppval(Load_spline(1),t_all)))-.5 max(max(ppval(Load_spline(1),t_all)))+.5])
    set(gca,'FontSize',fontsize)
    xlabel('Time (minutes) ')
    ylabel('Load (MW) ')
    
 
    t_Pref_line = 0:300:300*i;
    for k=1:length(t_Pref_line)
        lk=Pref_check(:,1)==t_Pref_line(k);
        Preflk=Pref_check(lk,:);
        Pref_lines(k)=Preflk(end,2);
    end
    Pref_linear_int = interp1(t_Pref_line,Pref_lines*ps.baseMVA,Pref_t);

    figure; hold on;
    plot(t_all_minute,Pm_all.*ps.baseMVA);
    plot(Pref_t/60,Pref_1*ps.baseMVA,'m-')%,'MarkerSize',1)
    plot(Pref_t/60,Pref_2*ps.baseMVA,'r-')%,'MarkerSize',1)
    %plot(Pref_t/60,Pref_linear_int,'g.','MarkerSize',1)
    plot(t_all_minute,omega_all/3.77)
    axis([tmin day_in_s/60 min(min(Pm_all.*ps.baseMVA))-.5 max(max(Pm_all.*ps.baseMVA))+.5])
    set(gca,'FontSize',fontsize)
    xlabel('Time (minutes) ')
    ylabel('Pm (MW) ') 
    legend('Pm, Area 1','Pm, Area 2','Pref, Area 1','Pref, Area 2','omega','omega2')%,'
    
    figure; hold on;
    plot(t_all_minute,delta_Pc_all*ps.baseMVA);
    plot(delta_Pc_lim_t/60,delta_Pc_lim_1*ps.baseMVA,'b')
    plot(delta_Pc_lim_t/60,delta_Pc_lim_2*ps.baseMVA,'g')
    axis([tmin day_in_s/60 min(min(delta_Pc_all*ps.baseMVA))-.02 max(max(delta_Pc_all*ps.baseMVA))+.02])
    set(gca,'FontSize',fontsize)
    xlabel('Time (minutes) ')
    ylabel('delta Pc (MW) ')
    legend('delta Pc 1','delta Pc 2','delta Pc 1 limited','delta Pc 2 limited')
    
    
    %% from will
    % Check standards
    disp('Testing NERC Standards')
    epsilon_1 = 11.6e-3;
    [ACE,CPS1_scores,CPS2_scores,CPS1,CPS2] = checkStandards_will(ps,omega_all,theta_all,t_all,epsilon_1);
    
  
end



