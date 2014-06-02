load load_days_splines.mat
middle_day_sp=load_days_splines(5);
t=0:86400;
load_day=ppval(middle_day_sp,t);
figure(2);clf;
plot(t(1:600),load_day(1:600));hold on;
mu=1;
noise = mrrw(length(load_day),1/60,1,2,10)-mu; %-mu to make 0 mean
noise=noise*5
noisy_load = load_day+noise;
plot(t(1:600),noisy_load(1:600),'g')
figure(1);clf;
plot(noise(1:600))

