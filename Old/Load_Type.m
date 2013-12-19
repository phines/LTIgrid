function [Load_spline,ps] = Load_Type(Val,ps,tmax)
%Load_Type forms a load for trial with sim_grid
%  For Val=1, a random load profile is created
%  For Val=2, a random load profile is created using a "light" mean reverting random walk
%  For Val=3, a random load profile is created using a "strong" mean reverting random walk
%  For Val=4, a simple load profile is created where one of the 3 total loads is increase by 0.5% and then decreased back to the original
%  For Val=5, a load profile is created in which each of the three loads is brought to greater than one of the generator gen limits (thus area 2
%  will be outside gen limits, area 1 shouldn't be)
C = psconstants_will;
initial_load     = ps.shunt(:,C.sh.P);
    
if Val == 1
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
    
elseif Val == 2
    load_points  = zeros(tmax,3);
    var_light    = zeros(3,1);
    std_light    = zeros(3,1);

    for i=1:length(initial_load)
       lp = mrrw(tmax,.01,10,1,1);
       load_points(:,i) = lp*(initial_load(i)/10); %hardcoded for ten in mrrw to be same value we divide by
       var_light(i)     = var(load_points(:,i));
       std_light(i)     = std(load_points(:,i));
    end

    time = 1:tmax;
    Load_spline1  = spline(time,load_points(:,1));
    Load_spline2  = spline(time,load_points(:,2)); %%unhardcode - number of loads should be naturally chosen 
    Load_spline3  = spline(time,load_points(:,3)); %%be sure to unhardcode subfunction (algebraic_lk.. as well)
    Load_spline   = [Load_spline1;Load_spline2;Load_spline3];

elseif Val == 3
    load_points   = zeros(tmax,3);
    var_strong    = zeros(3,1);
    std_strong    = zeros(3,1);

    for i=1:length(initial_load)
       lp = mrrw(tmax,.02,10,2,1.5);
       load_points(:,i)  = lp*(initial_load(i)/10); %hardcoded for ten in mrrw to be same value we divide by
       var_strong(i)     = var(load_points(:,i));
       std_strong(i)     = std(load_points(:,i));
    end

    time = 1:tmax;
    Load_spline1  = spline(time,load_points(:,1));
    Load_spline2  = spline(time,load_points(:,2)); %%unhardcode - number of loads should be naturally chosen 
    Load_spline3  = spline(time,load_points(:,3)); %%be sure to unhardcode subfunction (algebraic_lk.. as well)
    Load_spline   = [Load_spline1;Load_spline2;Load_spline3];

elseif Val == 4
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
    ps.areas(:,C.ar.B)=[round(max_load_area_1*0.01*10);round(max_load_area_2*0.01*10)];

elseif Val == 5
    load_points   = zeros(tmax,3);
    var_strong    = zeros(3,1);
    std_strong    = zeros(3,1);

    step = ceil((ps.gen(:,C.gen.Pmax)-initial_load)/tmax)
    for i=1:length(initial_load)
       load_points(:,i)  = initial_load(i):step(i):initial_load(i)+step(i)*(tmax-1);
       var_strong(i)     = var(load_points(:,i));
       std_strong(i)     = std(load_points(:,i));
    end

    time = 1:tmax;
    Load_spline1  = spline(time,load_points(:,1));
    Load_spline2  = spline(time,load_points(:,2)); %%unhardcode - number of loads should be naturally chosen 
    Load_spline3  = spline(time,load_points(:,3)); %%be sure to unhardcode subfunction (algebraic_lk.. as well)
    Load_spline   = [Load_spline1;Load_spline2;Load_spline3];
end


end

