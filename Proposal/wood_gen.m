[num,txt,raw]=xlsread('Wood_plant_far_north_gen_2013_15_min.xlsx');

wood_set = num(12000:12799,:);
powerKW = wood_set(:,3);
powerMW = powerKW/1000;
figure(2); clf; hold on;
plot(0.25:0.25:200,powerMW,'r')
title('VT Thermal Generator Power Output')
xlabel('Time (hours)')
ylabel('Power(MW)')
axis tight;

