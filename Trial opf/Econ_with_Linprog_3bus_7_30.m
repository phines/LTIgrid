clc
clear all

%% Load infortmation
All_Load            = importdata('load.mat');
One_Day             = All_Load{133}; %% choose one random day's load
One_Day_Hour_Chunks = One_Day(1:12:end)*.03; %scaled to fit current Pmax's, 5 min res, so to get 1hr time steps, pull 1st of every 12 points


%% Power System information
%ps      = case3_ps;
ps     = case6ww_lk;
gencost = ps.gencost;
busdata = ps.bus;
gendata = ps.gen;
PgSS    = [One_Day_Hour_Chunks(1)*.3;One_Day_Hour_Chunks(1)*.2;One_Day_Hour_Chunks(1)*.3]; % unhardcode this
S_cost  = 100;

%% Useful definitions
num_gens       = size(gendata,1);
num_time_steps = size(One_Day_Hour_Chunks,1);
num_both       = num_gens*num_time_steps;
Pmin           = gendata(:,10);
Pmax           = gendata(:,9);
RRu            = gendata(:,22); %%note, I added this gendata column, so should be updated.
RRd            = -RRu;


%% Setup inputs
c  = zeros((num_gens+2)*num_time_steps,1); % that length b/c x is of the form Pg1(k=1);Pg2(k=1);S+(k=1);S-(k=1);Pg1(k=2);Pg2(k=2);...Pg1(k=end);Pg2(k=end);S+(k=end);S-(k=end), and c, lb, and ub must be of the same length
lb = zeros((num_gens+2)*num_time_steps,1);
ub = zeros((num_gens+2)*num_time_steps,1);

for k=1:num_time_steps 
    curr_loc     = (1:num_gens+2) + (k-1)*(num_gens+2);
    c(curr_loc)  = vertcat(gencost(:,6),S_cost,-S_cost);
    lb(curr_loc) = vertcat(Pmin,0,-Inf); %lower bound of S+=0,S-=-Inf
    ub(curr_loc) = vertcat(Pmax,Inf,0); %upper bound of S+=inf, S-=0
end

lb(1:num_gens) = max(Pmin,RRd+PgSS); 
ub(1:num_gens) = min(Pmax,RRu+PgSS);

%%

rows         = 1:(num_time_steps-1)*num_gens;
cols         = 1:(num_gens+2)*(num_time_steps);
cols_0       = num_gens+1:num_gens+2:(num_gens+2)*(num_time_steps);
cols_0       = horzcat(cols_0,cols_0+1);
cols(cols_0) = [];
cols_a       = cols(rows);
cols2        = cols_a+(num_gens+2);
A_ru         = sparse(rows,cols_a,-1,(num_time_steps-1)*num_gens,(num_gens+2)*(num_time_steps));
A_ru         = A_ru + sparse(rows,cols2,1,(num_time_steps-1)*num_gens,(num_gens+2)*(num_time_steps));
A_rd         = sparse(rows,cols_a,1,(num_time_steps-1)*num_gens,(num_gens+2)*(num_time_steps));
A_rd         = A_rd + sparse(rows,cols2,-1,(num_time_steps-1)*num_gens,(num_gens+2)*(num_time_steps));
A            = [A_ru;A_rd];
b_ru         = repmat(RRu,num_time_steps-1,1);
b_rd         = repmat(-RRd,num_time_steps-1,1);
b            = [b_ru;b_rd];

Aeq = sparse(num_time_steps, num_time_steps*(num_gens+2));
beq = zeros(num_time_steps,1);


for k = 1:num_time_steps
    curr_loc = (1:num_gens+2) + (k-1)*(num_gens+2);
    Aeq      = Aeq + sparse(k,curr_loc,+1,num_time_steps, (num_gens+2)*(num_time_steps));
end

beq = One_Day_Hour_Chunks;
%%
[Pgs,~,exit] = linprog(c,A,b,Aeq,beq,lb,ub);
Pg12 = Pgs(cols);
Pgs_side_by_side = [Pg12(1:3:end),Pg12(2:3:end),Pg12(3:3:end)];%unhardcode
S_plus = Pgs(cols_0(1:end/2));
S_minus = Pgs(cols_0(end/2+1:end));

figure(1);clf;
plot(One_Day_Hour_Chunks,'ko')
hold on
plot(Pgs_side_by_side(:,1),'g.')
plot(Pgs_side_by_side(:,2),'m*')
plot(Pgs_side_by_side(:,3),'cd')
plot(sum(Pgs_side_by_side,2),'b')
plot(S_plus,'rx')
legend('Load','Pg1','Pg2','Pg3','PgSum','S+')
legend('Location','northwest')
axis([0,24.5,0,560])
