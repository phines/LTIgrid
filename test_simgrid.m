% load some data

C = psconstants;
ps = case9_ps; % get the real one?
ps = updateps(ps);
ps = dcpf(ps); % dc power flow
tmax = 10;
ps0 = ps;
nmacs = size(ps.gen,1);
n = size(ps.bus,1);
ix = get_indices(n,nmacs); % index to help us find stuff


% prepare the machine state variables
ps.mac = get_mac_state(ps,'linear');

% Simulate the steady state
[t1,theta1,delta1,omega1,Pm1,ps] = simgrid_lti(ps,[0,1]);

% try to increase one of the loads
ps.shunt(:,C.sh.P) = ps.shunt(:,C.sh.P) * 1.01;
[t2,theta2,delta2,omega2,Pm2,ps] = simgrid_lti(ps,[1,2]);

% now set the loads back to where they were
ps.shunt = ps0.shunt;
[t3,theta3,delta3,omega3,Pm3,ps] = simgrid_lti(ps,[2,tmax]);

t = [t1' t2' t3'];
theta = [theta1' theta2' theta3'];
omega = [omega1' omega2' omega3'];
delta = [delta1' delta2' delta3'];

%% do some plots
figure(3); clf;
subplot(3,1,1)
plot(t,delta);
axis([0 tmax -Inf Inf])
xlabel('time')
ylabel('delta')
title('Load change of 1%','fontsize',15)

subplot(3,1,2)
plot(t,theta);
axis([0 tmax -Inf Inf])
xlabel('time')
ylabel('theta')

subplot(3,1,3)
plot(t,omega);
axis([0 tmax -Inf Inf])
xlabel('time')
ylabel('omega')

