All = load('ISO-NewEngland 5 Minute Total Load No Text.csv');  
day_old=All(1,3);
E=0;
n_pnts=0;
days_info = [];
x=[];
for i=1:length(All) %fix
    day=All(i,3);
    if day_old==day
        E=E+All(i,7);
        n_pnts=n_pnts+1;
        t=datenum(All(i,1:6));
        n_line=[t,All(i,7)];
        x=[x;n_line];
    else
        tt=datenum(All(i-1,1),All(i-1,2),All(i-1,3),0,0,0):.001:datenum(All(i-1,1),All(i-1,2),All(i-1,3),23,59,59);
        yy=spline(x(:,1),x(:,2),tt);
        Espline=sum(yy);
        next_line=[All(i-1,1),All(i-1,2),All(i-1,3),E,n_pnts,Espline,E/n_pnts];
        days_info=[days_info;next_line];
        E=All(i,7);
        n_pnts=1;
        day_old=All(i,3);
        x=[];
    end
end
%%
days_info_sorted_tot_sp = sortrows(days_info,6);
days_info_sorted_tot_sp = days_info_sorted_tot_sp(end:-1:1,:);
days_info_sorted_avg = sortrows(days_info,7); 
days_info_sorted_avg = days_info_sorted_avg(end:-1:1,:);
a=days_info_sorted_tot_sp(:,5)<280;
days_info_sorted_tot_sp(a,:)=[];

figure;
plot(days_info_sorted_avg(:,7))
title('Daily Average Load Duration Curve')
ylabel('Average Daily Load, MW')
xlabel('Days')

figure;
plot(days_info_sorted_tot_sp(:,6))
title('Daily Total Load Duration Curve')
ylabel('Total Daily Load, MW')
xlabel('Days')

%% choose our random 10 days
num_days = length(days_info_sorted_tot_sp)
rand_days=[];

for i=1:10
    a=randi(floor(num_days/10),1);
    rand_days(i,:)=days_info_sorted_tot_sp(a+((i-1)*floor(num_days/10)),:);
end

%% find 10 days info
load_days_splines=[];
for i=1:10
    curr_y = rand_days(i,1);
    curr_m = rand_days(i,2);
    curr_d = rand_days(i,3);
    Curr_all = All(All(:,1)==curr_y,:);
    Curr_all = Curr_all(Curr_all(:,2)==curr_m,:);
    Curr_all = Curr_all(Curr_all(:,3)==curr_d,:);
    t_in_s   = Curr_all(:,4)*60*60+Curr_all(:,5)*60+Curr_all(:,6);
    Curr_load_spline = spline(t_in_s,Curr_all(:,7));
    load_days_splines=[load_days_splines;Curr_load_spline];
    t_check=0:86400;
    load_check = ppval(Curr_load_spline,t_check);
    figure(i);
    plot(t_check,load_check);
end


