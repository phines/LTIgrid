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

%% form the load
[Load_spline, ps] = Load_Type(4,ps,tmax);

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

