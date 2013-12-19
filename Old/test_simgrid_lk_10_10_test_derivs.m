global Load_spline

% load some data

C = psconstants_will;

ps = case9_ps_lk_9_18; % get the real one?
ps = updateps(ps);
ps = dcpf(ps); % dc power flow
tmin=1;
tmax = tmin+59;
ps0 = ps;
nmacs = size(ps.gen,1);
n = size(ps.bus,1);
ix = get_indices_will(n,nmacs); % index to help us find stuff
ps = find_areas(ps);
% prepare the machine state variables
ps.mac = get_mac_state(ps,'linear');

%% spline some fabricated load data
initial_load     = ps.shunt(:,C.sh.P);
load_points      = initial_load';
load_noise_scale = 2; %see what changing this does
for i=1:(tmax-1)
    load_points(i+1,:)=load_points(i,:)+load_noise_scale*randn(1,3);
end

time = 1:tmax;
Load_spline1  = spline(time,load_points(:,1));
Load_spline2  = spline(time,load_points(:,2)); %%unhardcode - number of loads should be naturally chosen 
Load_spline3  = spline(time,load_points(:,3)); %%be sure to unhardcode subfunction (algebraic_lk.. as well)
Load_spline   = [Load_spline1;Load_spline2;Load_spline3];

max_load = (max(load_points));
max_load_area_1 = max_load(3);
max_load_area_2 = max_load(1)+max_load(2);
ps.areas(2,:)=[round(max_load_area_1*0.01*10),round(max_load_area_2*0.01*10)];
%% spline the other style of load
initial_load     = ps.shunt(:,C.sh.P);
load_change      = ps.shunt(:,C.sh.P).*[1.005;1;1];
load = [repmat(initial_load,1,tmax/3), repmat(load_change,1,2*tmax/3)];%,repmat(initial_load,1,tmax/3)];
load = load';

time = 1:tmax;
Load_spline1  = spline(time,load(:,1));
Load_spline2  = spline(time,load(:,2)); %%unhardcode - number of loads should be naturally chosen 
Load_spline3  = spline(time,load(:,3)); %%be sure to unhardcode subfunction (algebraic_lk.. as well)
Load_spline   = [Load_spline1;Load_spline2;Load_spline3];

max_load = (max(load));
max_load_area_1 = max_load(3);
max_load_area_2 = max_load(1)+max_load(2);
ps.areas(2,:)=[round(max_load_area_1*0.01*10),round(max_load_area_2*0.01*10)];

%%


%% Simulate the steady state

[t,theta,delta,omega,Pm,ps] = simgrid_lti_lk_8_27(ps,[tmin,tmax],1);

