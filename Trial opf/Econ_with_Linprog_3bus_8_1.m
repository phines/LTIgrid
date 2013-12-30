clc
clear all

%% Load infortmation
All_Load            = importdata('load.mat');
One_Day             = All_Load{133}; %% choose one random day's load
One_Day_Hour_Chunks = One_Day(1:72:end)*.1; %scaled to fit current Pmax's, 5 min res, so to get 1hr time steps, pull 1st of every 12 points


%% Power System information
ps      = case3_ps;
%ps     = case6ww_lk;
gencost = ps.gencost;
busdata = ps.bus;
gendata = ps.gen;
PgSS    = [One_Day_Hour_Chunks(1)*.4;One_Day_Hour_Chunks(1)*.4]%;One_Day_Hour_Chunks(1)*.3]; % unhardcode this
S_cost  = 1000;

%% Useful definitions
num_gens       = size(gendata,1);
num_time_steps = size(One_Day_Hour_Chunks,1);
num_both       = num_gens*num_time_steps;
Pmin           = gendata(:,10);
Pmax           = gendata(:,9);
RRu            = gendata(:,22); %%note, I added this gendata column, so should be updated.
RRd            = -RRu;
RRreg          = RRu; %is this right?
reg_cost       = ones(num_gens,1);%will had cost=1, unhardcode
reg_total      = 0.01*One_Day_Hour_Chunks;
%% Setup inputs
c  = zeros((2*num_gens+2)*num_time_steps,1); % that length b/c x is of the form Pg1(k=1);Pg2(k=1);S+(k=1);S-(k=1);Pg1(k=2);Pg2(k=2);...Pg1(k=end);Pg2(k=end);S+(k=end);S-(k=end), and c, lb, and ub must be of the same length
lb = zeros((2*num_gens+2)*num_time_steps,1);
ub = zeros((2*num_gens+2)*num_time_steps,1);

for k=1:num_time_steps 
    curr_loc     = (1:2*num_gens+2) + (k-1)*(2*num_gens+2);
    c(curr_loc)  = vertcat(gencost(:,6),S_cost,-S_cost,reg_cost);
    lb(curr_loc) = vertcat(Pmin,0,-Inf,zeros(num_gens,1)); %lower bound of S+=0,S-=-Inf, Reg=0
    ub(curr_loc) = vertcat(Pmax,Inf,0,RRreg); %upper bound of S+=inf, S-=0, Reg=RRreg
end

lb(1:num_gens) = max(Pmin,RRd+PgSS); 
ub(1:num_gens) = min(Pmax,RRu+PgSS);

%%

rows         = 1:(num_time_steps-1)*num_gens;
cols         = 1:(2*num_gens+2)*(num_time_steps);
cols_0       = num_gens+1:2*num_gens+2:(2*num_gens+2)*(num_time_steps);
cols_0       = horzcat(cols_0,cols_0+1); %%%%%%
cols(cols_0) = [];
cols_a       = cols(rows);
cols2        = cols_a+(num_gens+2);
rows_odd_reg  = 1:2:2*num_gens*num_time_steps;
rows_even_reg = 2:2:2*num_gens*num_time_steps;
cols_reg = 1:2*num_gens+2:num_time_steps*(2*num_gens+2);
cols_reg = sort([cols_reg,cols_reg+1]);
cols_reg_2 = cols_reg+num_gens+2;
A_ru         = sparse(rows,cols_reg(rows),-1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_ru         = A_ru + sparse(rows,cols_reg_2(rows),1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_rd         = sparse(rows,cols_reg(rows),1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_rd         = A_rd + sparse(rows,cols_reg_2(rows),-1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_reg = sparse(rows_odd_reg,cols_reg,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_odd_reg,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_even_reg,cols_reg,-1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_even_reg,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));

A            = [A_ru;A_rd;A_reg];
b_ru         = repmat(RRu,num_time_steps-1,1);

%% 
clear all
num_time_steps = 4
num_gens = 3

rows         = 1:(num_time_steps-1)*num_gens;
cols         = 1:(2*num_gens+2)*(num_time_steps);
cols_0       = num_gens+1:2*num_gens+2:(2*num_gens+2)*(num_time_steps);
cols_0       = horzcat(cols_0,cols_0+1); %%%%%%
cols(cols_0) = [];
cols_a       = cols(rows);
cols2        = cols_a+(num_gens+2);
rows_odd_reg  = 1:2:2*num_gens*num_time_steps;
rows_even_reg = 2:2:2*num_gens*num_time_steps;
cols_reg = 1:2*num_gens+2:num_time_steps*(2*num_gens+2);
cols_reg = sort([cols_reg,cols_reg+1]);
cols_reg_2 = cols_reg+num_gens+2;
A_ru         = sparse(rows,cols_reg(rows),-1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_ru         = A_ru + sparse(rows,cols_reg_2(rows),1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_rd         = sparse(rows,cols_reg(rows),1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_rd         = A_rd + sparse(rows,cols_reg_2(rows),-1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_reg = sparse(rows_odd_reg,cols_reg,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_odd_reg,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_even_reg,cols_reg,-1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_even_reg,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));

A            = [A_ru;A_rd;A_reg];

b_rd         = repmat(-RRd,num_time_steps-1,1);

Plims      = [Pmax';-Pmin'];
Plims_size = size(Plims);
b_reg      = reshape(Plims,Plims_size(1)*Plims_size(2),1);
b_reg      = repmat(b_reg,num_time_steps,1)
b          = [b_ru;b_rd;b_reg];

Aeq_top = sparse(num_time_steps, num_time_steps*(2*num_gens+2));
Aeq_bot = sparse(num_time_steps, num_time_steps*(2*num_gens+2));

for k = 1:num_time_steps
    curr_loc_top = (1:num_gens+2) + (k-1)*(2*num_gens+2);
    curr_loc_bot = (1:num_gens) + (k-1)*(2*num_gens+2) + num_gens+2;
    Aeq_top      = Aeq_top + sparse(k,curr_loc_top,+1,num_time_steps, (2*num_gens+2)*(num_time_steps));
    Aeq_bot      = Aeq_bot + sparse(k,curr_loc_bot,+1,num_time_steps, (2*num_gens+2)*(num_time_steps));
end

Aeq = [Aeq_top; Aeq_bot];
beq = [One_Day_Hour_Chunks;reg_total];



%% 
[Pgs,~,exit] = linprog(c,A,b,Aeq,beq,lb,ub);

for i=1:num_gens
   Pgs_sbs(:,i) = Pgs(i:2*num_gens+2:length(Pgs))   
   Rgs_sbs(:,i) = Pgs(num_gens+2+i:2*num_gens+2:length(Pgs))
end

S_plus = Pgs(cols_0(1:end/2));
S_minus = Pgs(cols_0(end/2+1:end));

figure(1);clf;
plot(One_Day_Hour_Chunks,'ko')
hold on
plot(Pgs_sbs(:,1),'g.')
plot(Pgs_sbs(:,2),'m*')
%plot(Pgs_side_by_side(:,3),'cd')
plot(sum(Pgs_sbs,2),'b')
plot(S_plus,'rx')
legend('Load','Pg1','Pg2','PgSum','S+')
legend('Location','northwest')
axis([0,24.5,0,1560])
