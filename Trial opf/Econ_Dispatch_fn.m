function [ps,Pgs_sbs,Rgs_sbs] = Econ_Dispatch_fn(ps,Load)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
 

C     = psconstants_will;
%% Load infortmation
if exist('Load','var') %make this work without just empty or Load given
    %Is it ok to treat load as one total value?
    One_Day_Hour_Chunks = Load;
else 
    All_Load            = importdata('load.mat');
    One_Day             = All_Load{133}; %% choose one random day's load
    One_Day_Hour_Chunks = One_Day(1:12:end)*.03; %scaled to fit current Pmax's, 5 min res, so to get 1hr time steps, pull 1st of every 12 points
end

%% Power System information
%gencost = ps.gencost;
%busdata = ps.bus;
gendata = ps.gen;
%gendata(:,C.ge.ramp_rate_up) = gendata(:,C.ge.Pmax).*[0.3;6;1];%use for case9_ps_lk_perm ONLY, UNHARDCODE, is this right (I think) or should it be reg ramp up?

% for i = 1:size(gendata,1)
% PgSS(i,1) = One_Day_Hour_Chunks(1)/size(gendata,1); 
% end
PgSS = ps.gen(:,C.ge.Pg);

% ADD PSCONSTANTS AND USE
S_cost  = 1000;

%% Useful definitions
%look at how will does indexing
num_gens       = size(gendata,1);
num_time_steps = size(One_Day_Hour_Chunks,1);
num_both       = num_gens*num_time_steps;
Pmin           = gendata(:,C.ge.Pmin);
Pmax           = gendata(:,C.ge.Pmax);
RRu            = gendata(:,C.ge.ramp_rate_up); %%note, I added this gendata column, so should be updated.
RRd            = -RRu;
RRreg          = RRu; %is this right?
reg_cost       = ones(num_gens,1);%will had cost=1, unhardcode
reg_total      = 0.01*One_Day_Hour_Chunks; %make the %reg specifiable as input
%% Setup inputs
c  = zeros((2*num_gens+2)*num_time_steps,1); % that length b/c x is of the form Pg1(k=1);Pg2(k=1);S+(k=1);S-(k=1);Pg1(k=2);Pg2(k=2);...Pg1(k=end);Pg2(k=end);S+(k=end);S-(k=end), and c, lb, and ub must be of the same length
lb = zeros((2*num_gens+2)*num_time_steps,1);
ub = zeros((2*num_gens+2)*num_time_steps,1);

for k=1:num_time_steps 
    curr_loc     = (1:2*num_gens+2) + (k-1)*(2*num_gens+2);
    c(curr_loc)  = vertcat(gendata(:,C.ge.cost),S_cost,-S_cost,reg_cost); %check that C.ge.cost=linear column of gencost
    lb(curr_loc) = vertcat(Pmin,0,-Inf,zeros(num_gens,1)); %lower bound of S+=0,S-=-Inf, Reg=0
    ub(curr_loc) = vertcat(Pmax,Inf,0,RRreg); %upper bound of S+=inf, S-=0, Reg=RRreg
end

lb(1:num_gens) = max(Pmin,RRd+PgSS); 
ub(1:num_gens) = min(Pmax,RRu+PgSS);

%%

cols=[];
for i=1:num_time_steps
   curr_a = (1:num_gens)+(i-1)*(2*num_gens+2); 
   cols = horzcat(cols,curr_a);
end

rows          = 1:(num_time_steps-1)*num_gens;
cols_2        = cols+(2*num_gens+2);
rows_odd_reg  = 1:2:2*num_gens*num_time_steps;
rows_even_reg = 2:2:2*num_gens*num_time_steps;
cols_reg_2    = cols + num_gens+2;

A_ru  = sparse(rows,cols(rows),-1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_ru  = A_ru + sparse(rows,cols_2(rows),1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_rd  = sparse(rows,cols(rows),1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_rd  = A_rd + sparse(rows,cols_2(rows),-1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_reg = sparse(rows_odd_reg,cols,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_odd_reg,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_even_reg,cols,-1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_even_reg,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
 
A = [A_ru;A_rd;A_reg];

b_ru  = repmat(RRu,num_time_steps-1,1);
b_rd  = repmat(-RRd,num_time_steps-1,1);

Plims      = [Pmax';-Pmin'];
Plims_size = size(Plims);
b_reg      = reshape(Plims,Plims_size(1)*Plims_size(2),1);
b_reg      = repmat(b_reg,num_time_steps,1);
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
   Pgs_sbs(:,i) = Pgs(i:2*num_gens+2:length(Pgs));
   Rgs_sbs(:,i) = Pgs(num_gens+2+i:2*num_gens+2:length(Pgs));
end

S_plus = Pgs(num_gens+1:2*num_gens+2:end);
S_minus = Pgs(num_gens+2:2*num_gens+2:end);

cmap = hsv(num_gens); 

figure(1);clf;
hold on
plot(One_Day_Hour_Chunks,'ko')
legend_str{1} = 'Load';
plot(sum(Pgs_sbs,2),'b')
legend_str{2} = 'Pgsum';
plot(S_plus,'rx')
legend_str{3} = 'S Plus';
symbols = ['.' 'x' '+' '*' 's' 'd' '^'];

m=0;
for i=1:num_gens
    m=m+1;
    plot(Pgs_sbs(:,i),symbols(m),'Color',cmap(i,:))
    if m==7
        m=0; % is there a better way to do this with mod?
    end
    i_str = num2str(i);
    legend_str_curr=strcat('Pg',i_str);
    legend_str {i+3}=legend_str_curr;
end

legend(legend_str)
legend('Location','northwest')
axis([.9,length(One_Day_Hour_Chunks)+.3,0,max(One_Day_Hour_Chunks)+200])

end

