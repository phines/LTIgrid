

lk1 = mrrw(60,.01,10,1,1);
lk1 = lk1*(initial_load(1)/10)
var1 = var(lk1)
std1 = std(lk1)
% figure;clf
% plot(lk1*10,'r-')

time=1:60;
time2 = 1:0.01:60;
rwload = spline(time, lk1,time2);
figure(7);clf;
plot(rwload)
%ylim([90 110])

lk2 = mrrw(60,.02,10,2,1.5);
var2 = var(lk2)
std2 = std(lk2)
% figure;clf
% plot(lk2*10,'r-')

time=1:60;
time2 = 1:0.01:60;
rwload = spline(time, lk2,time2);
figure(8);clf;
plot(rwload*10)
ylim([90 110])

