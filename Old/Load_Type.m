function [Load_spline,ps] = Load_Type(Val,ps,tmax,bus_areas)
%Load_Type forms a load for trial with sim_grid
%  For Val=1, a random load profile is created
%  For Val=2, a random load profile is created using a "light" mean reverting random walk
%  For Val=3, a random load profile is created using a "strong" mean reverting random walk
%  For Val=4, a simple load profile is created where one of the loads is increase by 0.5% and then decreased back to the original
%  For Val=5, a load profile is created in which each of the three loads is brought to greater than one of the generator gen limits (thus area 2
%  will be outside gen limits, area 1 shouldn't be)
C = psconstants_will;
initial_load     = ps.shunt(:,C.sh.P);

if Val == 1
    load_points      = initial_load';
    load_noise_scale = 2; %see what changing this does
    for i=1:(tmax-1)
        load_points(i+1,:)=load_points(i,:)+load_noise_scale*randn(1,length(initial_load));
    end

    time = 1:tmax;
    Load_spline = spline(time,load_points');
   
    max_load = (max(load_points));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];
    %should the above line be everywhere?
    
elseif Val == 2
    load_points  = zeros(tmax,3);
    var_light    = zeros(3,1);
    std_light    = zeros(3,1);
    time         = 1:tmax;

    for i=1:length(initial_load)
       lp = mrrw(tmax,.01,10,1,1);
       load_points(:,i)  = lp*(initial_load(i)/10); %hardcoded for ten in mrrw to be same value we divide by
       var_light(i)      = var(load_points(:,i));
       std_light(i)      = std(load_points(:,i));
    end
    Load_spline = spline(time,load_points');
elseif Val == 3
    load_points = zeros(tmax,length(initial_load));
    var_strong  = zeros(length(initial_load),1);
    std_strong  = zeros(length(initial_load),1);
    time        = 1:tmax;
 
    for i=1:length(initial_load)
       lp = mrrw(tmax,.02,10,2,1.5);
       load_points(:,i)  = lp*(initial_load(i)/10); %hardcoded for ten in mrrw to be same value we divide by
       var_strong(i)     = var(load_points(:,i));
       std_strong(i)     = std(load_points(:,i));
    end
    Load_spline = spline(time,load_points');
elseif Val == 4
    load_change     = initial_load;
    load_change_val = (1.005:.0005:1.05).*load_change(1);
    load            = repmat(initial_load,1,tmax);
    load(1,tmax/3:tmax/3+length(load_change_val)-1)=load_change_val;
    load(1,tmax/3+length(load_change_val):end)=load_change_val(end);
    load_points     = load';
    time = 1:tmax;
    Load_spline = spline(time,load_points');
    
    max_load = (max(load'));
    max_load_area_1 = sum(max_load(bus_areas==1));
    max_load_area_2 = sum(max_load(bus_areas==2));
    %also, (above) make sure the max of a given time is used, not max of
    %individual loads added together
    ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];

elseif Val == 5
    load_points = zeros(tmax,length(initial_load));
    var_strong  = zeros(length(initial_load),1);
    std_strong  = zeros(length(initial_load),1);
    time        = 1:tmax;
    step        = ceil((2*initial_load)/tmax); %2=random choice by me
    
    for i=1:length(initial_load)
       load_points(:,i)  = initial_load(i):step(i):initial_load(i)+step(i)*(tmax-1);
       var_strong(i)     = var(load_points(:,i));
       std_strong(i)     = std(load_points(:,i));
    end
    Load_spline = spline(time,load_points');
elseif Val == 6
    load_points = zeros(tmax,length(initial_load));
    var_strong  = zeros(length(initial_load),1);
    std_strong  = zeros(length(initial_load),1);
    time        = 1:tmax;
    step        = ceil((3*initial_load)/tmax);
    
    for i=1:length(initial_load)
        if i==1
           load_points(:,i)  = initial_load(i):step(i):initial_load(i)+step(i)*(tmax-1);
           var_strong(i)     = var(load_points(:,i));
           std_strong(i)     = std(load_points(:,i));
        else
            load_points(:,i) = initial_load(i)*ones(tmax,1);
        end
    end
    Load_spline = spline(time,load_points');
end

end

