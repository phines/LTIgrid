clc
clear all

%% Load infortmation
All_Load            = importdata('load.mat');
One_Day             = All_Load{133}; %% choose one random day's load
One_Day_Hour_Chunks = One_Day(1:12:end)*.05; %scaled to fit current Pmax's, 5 min res, so to get 1hr time steps, pull 1st of every 12 points


%% Power System information
ps      = case3_ps;
%ps     = case6ww_lk;
gencost = ps.gencost;
busdata = ps.bus;
gendata = ps.gen;
PgSS    = [One_Day_Hour_Chunks(1)*.2;One_Day_Hour_Chunks(1)*.4;];

%% Useful definitions
num_gens       = size(gendata,1);
num_time_steps = size(One_Day_Hour_Chunks,1);
num_both       = num_gens*num_time_steps;
Pmin           = gendata(:,10);
Pmax           = gendata(:,9);
RRu            = gendata(:,22); %%note, I added this gendata column, so should be updated.
RRd            = -RRu;


%% Setup inputs
c  = zeros(num_both,1); % for that length b/c x is of the form Pg1(k=1);Pg2(k=1);Pg1(k=2);Pg2(k=2);...Pg1(k=end);Pg2(k=end), and c, lb, and ub must be of the same length
lb = zeros(num_both,1);
ub = zeros(num_both,1);

for k=1:num_time_steps 
    curr_loc     = (1:num_gens) + (k-1)*num_gens;
    c(curr_loc)  = gencost(:,6);
    lb(curr_loc) = Pmin;
    ub(curr_loc) = Pmax;
end

lb(1:num_gens) = max(Pmin,RRd+PgSS); 
ub(1:num_gens) = min(Pmax,RRu+PgSS);


A_ru = sparse(num_gens*(num_time_steps-1),num_both);
A_rd = sparse(num_gens*(num_time_steps-1),num_both);
b_ru = zeros(num_gens*(num_time_steps-1),1);
b_rd = zeros(num_gens*(num_time_steps-1),1);

rows  = 1:(num_time_steps-1)*num_gens;
cols  = rows;
cols2 = rows+2;
A_ru  = sparse(rows,cols,-1,(num_time_steps-1)*num_gens,num_both);
A_ru  = A_ru + sparse(rows,cols2,1,(num_time_steps-1)*num_gens,num_both);
A_rd  = sparse(rows,cols,1,(num_time_steps-1)*num_gens,num_both);
A_rd  = A_rd + sparse(rows,cols2,-1,(num_time_steps-1)*num_gens,num_both);
A     = [A_ru;A_rd];
b_ru  = repmat(RRu,num_time_steps-1,1);
b_rd  = repmat(-RRd,num_time_steps-1,1);
b     = [b_ru;b_rd];

Aeq = sparse(num_time_steps, num_both);
beq = zeros(num_time_steps,1);


for k = 1:num_time_steps
    curr_loc = (1:num_gens) + (k-1)*num_gens;
    Aeq      = Aeq + sparse(k,curr_loc,+1,num_time_steps, num_both);
end

beq = One_Day_Hour_Chunks;
%%
Pgs = linprog(c,A,b,Aeq,beq,lb,ub);
Pg1 = Pgs(1:2:end-1);
Pg2 = Pgs(2:2:end);
Pgs_side_by_side = [Pg1,Pg2];

figure(1);clf;
plot(Pg1,'go')
hold on
plot(Pg2,'mo')
plot(One_Day_Hour_Chunks,'ko')
legend('Pg1','Pg2','Load')
