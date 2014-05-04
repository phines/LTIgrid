load Pgs_sbs_all
load gen_type
load total_load
total_load_sum = sum(total_load)
total_load_sum=total_load_sum(1:288)
figure(1);clf;hold on
cmap = [1 0 0;0.33 0.7 0.8;0.66 .9 0;.8 .5 .5;.5 0 0.9;]

for i=1:length(gen_type)
   if gen_type(i)==1
       num=gen_type(i)
       plot(Pgs_sbs_all(i,:),'Color',cmap(num,:),'Linewidth',2)
   elseif gen_type(i)==2
       num=gen_type(i)
       plot(Pgs_sbs_all(i,:),'Color',cmap(num,:),'Linewidth',2)
   elseif gen_type(i)==3
       num=gen_type(i)
       plot(Pgs_sbs_all(i,:),'Color',cmap(num,:),'Linewidth',2)
   elseif gen_type(i)==4
       num=gen_type(i)
       plot(Pgs_sbs_all(i,:),'Color',cmap(num,:),'Linewidth',2)
   elseif gen_type(i)==5
       num=gen_type(i)
       plot(Pgs_sbs_all(i,:),'Color',cmap(num,:),'Linewidth',2)
   end
end
xlim([0,140])
xlabel('Time')
ylabel('Generator Power (MW)')
figure(2);clf;hold on
plot(total_load_sum)
xlim([0,140])
xlabel('Time')
ylabel('Load Power (MW)')