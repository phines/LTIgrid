function [Pgs_sbs,Rgs_sbs] = Econ_Dispatch_fn(ps,Load,perc_reg,disp_t)
%disp_t in minutes
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
 
C     = psconstants_will;
%% Load infortmation
if exist('Load','var') 
    One_Day_in_disp_t_Load = Load;
else 
    All_Load            = importdata('load.mat');
    One_Day             = All_Load{133}; %% choose one random day's load
    One_Day_in_disp_t_Load = One_Day(1:12:end)*.03; %scaled to fit current Pmax's, 5 min res, so to get 1hr time steps, pull 1st of every 12 points
    %above should be unhardcoded
end

%% Power System information

gendata   = ps.gen;
bus_areas = ps.bus(:,C.bu.area);
num_areas = length(unique(bus_areas));
S_cost    = 1000; %orig=1000
reg_frac  = perc_reg/100;
[gen_locs,load_locs] = get_locs(ps);
load_areas           = bus_areas(load_locs==1);
gen_areas            = bus_areas(gen_locs==1);
num_time_steps       = size(One_Day_in_disp_t_Load,2);
num_gens             = size(gen_areas,1);
Pgs_sbs              = zeros(num_gens,num_time_steps);
Rgs_sbs              = zeros(num_gens,num_time_steps);
%% Useful definitions
%look at how will does indexing

for j=1:num_areas
    gendata_area   = gendata(gen_areas==j,:);
    num_gens_area  = size(gendata_area,1);
    Pmin           = gendata_area(:,C.ge.Pmin);
    Pmax           = gendata_area(:,C.ge.Pmax);
    RRu            = gendata_area(:,C.ge.ramp_rate_up)*disp_t; %comes in as MW/min, want MW/deltat
    RRd            = -RRu;
    load_in_area   = One_Day_in_disp_t_Load(bus_areas==j,:); %how to take care of stochastic load here..?
    load_area_sum  = sum(load_in_area,1);  
    reg_scheduled  = load_area_sum*reg_frac; 
    percent_pmax   = Pmax/sum(Pmax);
    reg_per_gen    = percent_pmax*reg_scheduled;
    %reg_per_gen    = reg_scheduled/num_gens_area; %better way to do than divide evenly?
    
%% Setup inputs
    c  = zeros((num_gens_area+2)*num_time_steps,1); % that length b/c x is of the form Pg1(k=1);Pg2(k=1);S+(k=1);S-(k=1);Pg1(k=2);Pg2(k=2);...Pg1(k=end);Pg2(k=end);S+(k=end);S-(k=end), and c, lb, and ub must be of the same length
    lb = zeros((num_gens_area+2)*num_time_steps,1);
    ub = zeros((num_gens_area+2)*num_time_steps,1);
    cols=[];
    for k=1:num_time_steps 
        curr_loc     = (1:num_gens_area+2) + (k-1)*(num_gens_area+2);
        c(curr_loc)  = vertcat(gendata_area(:,C.ge.cost),S_cost,-S_cost); %check that C.ge.cost=linear column of gencost
        lb(curr_loc) = vertcat(Pmin+reg_per_gen(k),0,-Inf); %lower bound of S+=0,S-=-Inf, Reg=0
        ub(curr_loc) = vertcat(Pmax-reg_per_gen(k),Inf,0); %upper bound of S+=inf, S-=0, Reg=RRreg
        curr_a = (1:num_gens_area)+(k-1)*(num_gens_area+2); %+2?
        cols = horzcat(cols,curr_a);
    end

%     lb(1:num_gens) = max(Pmin,RRd+PgSS_area); 
%     ub(1:num_gens) = min(Pmax,RRu+PgSS_area);

    %%
    rows          = 1:(num_time_steps-1)*num_gens_area;
    cols_2        = cols+(num_gens_area+2);
    
    if num_time_steps==1
        A=[];
        b=[];
    else
        A_ru  = sparse(rows,cols(rows),-1,(num_time_steps-1)*num_gens_area,num_time_steps*(num_gens_area+2));
        A_ru  = A_ru + sparse(rows,cols_2(rows),1,(num_time_steps-1)*num_gens_area,num_time_steps*(num_gens_area+2));
        A_rd  = sparse(rows,cols(rows),1,(num_time_steps-1)*num_gens_area,num_time_steps*(num_gens_area+2));
        A_rd  = A_rd + sparse(rows,cols_2(rows),-1,(num_time_steps-1)*num_gens_area,num_time_steps*(num_gens_area+2));
        A = [A_ru;A_rd];

        b_ru  = repmat(RRu,num_time_steps-1,1);
        b_rd  = repmat(-RRd,num_time_steps-1,1); %consider minus signs
        b          = [b_ru;b_rd];
    end

    Aeq = sparse(num_time_steps, num_time_steps*(num_gens_area+2));

    for k = 1:num_time_steps
        curr_loc_top = (1:num_gens_area+2) + (k-1)*(num_gens_area+2);
        Aeq      = Aeq + sparse(k,curr_loc_top,+1,num_time_steps, (num_gens_area+2)*(num_time_steps));
    end
    
    beq = load_area_sum';

 

    %% 
    [Pgs,~,~] = linprog(c,A,b,Aeq,beq,lb,ub); 
    loc       = find(gen_areas==j);
   
    for i=1:num_gens_area
       Pgs_sbs(loc(i),:) = Pgs(i:num_gens_area+2:end);
    end

    Rgs_sbs(loc,:) = reg_per_gen;
    %S_plus = Pgs(num_gens_area+1:num_gens_area+2:end);
    %S_minus = Pgs(num_gens_area+2:num_gens_area+2:end);

    %cmap = hsv(num_gens_area); 

%     figure(1);clf;
%     hold on
%     plot(One_Day_Hour_Chunks,'ko')
%     legend_str{1} = 'Load';
%     plot(sum(Pgs_sbs,2),'b')
%     legend_str{2} = 'Pgsum';
%     plot(S_plus,'rx')
%     legend_str{3} = 'S Plus';
    %symbols = ['.' 'x' '+' '*' 's' 'd' '^'];

%     m=0;
%     for i=1:num_gens
%         m=m+1;
%         plot(Pgs_sbs(:,i),symbols(m),'Color',cmap(i,:))
%         if m==7
%             m=0; % is there a better way to do this with mod?
%         end
%         i_str = num2str(i);
%         legend_str_curr=strcat('Pg',i_str);
%         legend_str {i+3}=legend_str_curr;
%     end
% 
%     legend(legend_str)
%     legend('Location','northwest')
%    axis([.9,length(One_Day_Hour_Chunks)+.3,0,max(One_Day_Hour_Chunks)+200])

end

end

