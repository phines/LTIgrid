global Load_spline

% load some data

C = psconstants_will;
ps = case9_ps_lk_perm; % get the real one? K SHOULD BE 0.151, CHECK IT
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
ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];

%% spline spline fabricated load data (light mrrw)

initial_load = ps.shunt(:,C.sh.P);
load_points  = zeros(60,3);
var_light    = zeros(3,1);
std_light    = zeros(3,1);

for i=1:length(initial_load)
   lp = mrrw(60,.01,10,1,1);
   load_points(:,i) = lp*(initial_load(i)/10); %hardcoded for ten in mrrw to be same value we divide by
   var_light(i)     = var(load_points(:,i));
   std_light(i)     = std(load_points(:,i));
end

time = 1:tmax;
Load_spline1  = spline(time,load_points(:,1));
Load_spline2  = spline(time,load_points(:,2)); %%unhardcode - number of loads should be naturally chosen 
Load_spline3  = spline(time,load_points(:,3)); %%be sure to unhardcode subfunction (algebraic_lk.. as well)
Load_spline   = [Load_spline1;Load_spline2;Load_spline3];

%% spline spline fabricated load data (strong mrrw)
% 
% initial_load  = ps.shunt(:,C.sh.P);
% load_points   = zeros(60,3);
% var_strong    = zeros(3,1);
% std_strong    = zeros(3,1);
% 
% for i=1:length(initial_load)
%    lp = mrrw(60,.02,10,2,1.5);
%    load_points(:,i) = lp*(initial_load(i)/10); %hardcoded for ten in mrrw to be same value we divide by
%    var_strong(i)     = var(load_points(:,i));
%    std_strong(i)     = std(load_points(:,i));
% end
% 
% time = 1:tmax;
% Load_spline1  = spline(time,load_points(:,1));
% Load_spline2  = spline(time,load_points(:,2)); %%unhardcode - number of loads should be naturally chosen 
% Load_spline3  = spline(time,load_points(:,3)); %%be sure to unhardcode subfunction (algebraic_lk.. as well)
% Load_spline   = [Load_spline1;Load_spline2;Load_spline3];

 %% spline the other style of load
% initial_load     = ps.shunt(:,C.sh.P);
% load_change      = ps.shunt(:,C.sh.P).*[1.005;1;1];
% load = [repmat(initial_load,1,tmax/3), repmat(load_change,1,2*tmax/3)];%,repmat(initial_load,1,tmax/3)];
% load = load';
% 
% time = 1:tmax;
% Load_spline1  = spline(time,load(:,1));
% Load_spline2  = spline(time,load(:,2)); %%unhardcode - number of loads should be naturally chosen 
% Load_spline3  = spline(time,load(:,3)); %%be sure to unhardcode subfunction (algebraic_lk.. as well)
% Load_spline   = [Load_spline1;Load_spline2;Load_spline3];
% 
% max_load = (max(load));
% max_load_area_1 = max_load(3);
% max_load_area_2 = max_load(1)+max_load(2);
% ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];

%% Simulate the steady state

[t,theta,delta,omega,Pm,ps] = simgrid_lti_lk_perm(ps,[tmin,tmax],0);

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
hold on
plot(t, ppval(Load_spline(2),t),'b')
plot(t, ppval(Load_spline(3),t),'r')
%plot(t, ppval(Load_spline(3),t)+ppval(Load_spline(2),t)+ppval(Load_spline(1),t),'m')
axis([tmin tmax -Inf Inf])
set(gca,'FontSize',fontsize)
xlabel('Time')
ylabel('Load')

