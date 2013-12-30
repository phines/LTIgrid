% num_gens = 2;
% num_time_steps = 4;
% num_both=num_gens*num_time_steps;
% 
% A_ru = sparse(num_gens*(num_time_steps-1),(num_gens+2)*(num_time_steps));
% A_rd = sparse(num_gens*(num_time_steps-1),(num_gens+2)*(num_time_steps));
% b_ru = zeros(num_gens*(num_time_steps-1),1);
% b_rd = zeros(num_gens*(num_time_steps-1),1);
% 
% rows   = 1:(num_time_steps-1)*num_gens;
% cols   = 1:(num_gens+2)*(num_time_steps);
% cols_0 = num_gens+1:num_gens+2:(num_gens+2)*(num_time_steps);
% cols_0 = horzcat(cols_0,cols_0+1);
% cols(cols_0)=[];
% cols = cols(rows)
% cols2  = cols+4;
% A_ru   = sparse(rows,cols,-1,(num_time_steps-1)*num_gens,(num_gens+2)*(num_time_steps));
% A_ru   = A_ru + sparse(rows,cols2,1,(num_time_steps-1)*num_gens,(num_gens+2)*(num_time_steps));
% A_rd   = sparse(rows,cols,1,(num_time_steps-1)*num_gens,(num_gens+2)*(num_time_steps));
% A_rd   = A_rd + sparse(rows,cols2,-1,(num_time_steps-1)*num_gens,(num_gens+2)*(num_time_steps));
% A      = [A_ru;A_rd];
% libb=full(A)
% 
% %%
% A_ru1 = sparse(num_gens*(num_time_steps-1),num_both);
% A_rd1 = sparse(num_gens*(num_time_steps-1),num_both);
% 
% tic
% for k=2:num_time_steps
%     rows = (1:num_gens) + (k-2)*num_gens;
%     cols_cur  = (1:num_gens) + (k-1)*num_gens;
%     cols_prev = (1:num_gens) + (k-2)*num_gens;
%     A_ru1 = A_ru1 + sparse(rows,cols_cur ,+1,num_gens*(num_time_steps-1),num_both);
%     A_ru1 = A_ru1 + sparse(rows,cols_prev,-1,num_gens*(num_time_steps-1),num_both);
%     A_rd1 = A_rd1 + sparse(rows,cols_cur ,-1,num_gens*(num_time_steps-1),num_both);
%     A_rd1 = A_rd1 + sparse(rows,cols_prev,+1,num_gens*(num_time_steps-1),num_both);
% end
% toc
% A1 = [A_ru1;A_rd1];
% libb1 = full(A1);
% 
% %%
% 
% Aeq_top = sparse(num_time_steps, (num_gens+2)*(num_time_steps));
% for k = 1:num_time_steps
%     curr_loc_top = (1:num_gens+2) + (k-1)*(num_gens+2);
%     Aeq_top      = Aeq_top + sparse(k,curr_loc_top,+1,num_time_steps, (num_gens+2)*(num_time_steps));
%     libbeq     = full(Aeq_top);
% end
% 
% 
% %% 
% Aeq_top = sparse(num_time_steps, num_time_steps*(2*num_gens+2));
% Aeq_bot = sparse(num_time_steps, num_time_steps*(2*num_gens+2));
% beq = zeros(num_time_steps,1);
% 
% 
% for k = 1:num_time_steps
%     curr_loc_top = (1:num_gens+2) + (k-1)*(2*num_gens+2);
%     curr_loc_bot = (1:num_gens) + (k-1)*(2*num_gens+2) + num_gens+2
%     Aeq_top      = Aeq_top + sparse(k,curr_loc_top,+1,num_time_steps, (2*num_gens+2)*(num_time_steps));
%     Aeq_bot      = Aeq_bot + sparse(k,curr_loc_bot,+1,num_time_steps, (2*num_gens+2)*(num_time_steps));
% end
% 
% Aeq = [Aeq_top; Aeq_bot]
% beq = [One_Day_Hour_Chunks;] 
%     
% %%
% rows         = 1:(num_time_steps-1)*num_gens;
% cols         = 1:(2*num_gens+2)*(num_time_steps);
% cols_0       = num_gens+3:2*num_gens+2:(2*num_gens+2)*(num_time_steps);
% cols_0       = horzcat(cols_0,cols_0+1);
% cols(cols_0) = [];
% cols_a       = cols(rows);
% cols2        = cols_a+(num_gens+2);
% A            = [A_ru;A_rd];
% b_ru         = repmat(RRu,num_time_steps-1,1);
% b_rd         = repmat(-RRd,num_time_steps-1,1);
% b            = [b_ru;b_rd];
% 
% 
% 
% 
% %%
% rows_odd_reg  = 1:2:2*num_gens*num_time_steps
% rows_even_reg = 2:2:2*num_gens*num_time_steps
% 
% cols_reg = num_time_steps/2-1:2*num_gens+2:num_time_steps*(2*num_gens+2)
% cols_reg = sort([cols_reg,cols_reg+1])
% cols_reg_2 = cols_reg+num_gens+2
% 
% A_reg = sparse(rows_odd_reg,cols_reg,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2))
% A_reg = A_reg + sparse(rows_odd_reg,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2))
% A_reg = A_reg + sparse(rows_even,cols_reg,-1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2))
% A_reg = A_reg + sparse(rows_even,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2))
% 
% libb=full(A_reg)
% 
% Plims = [Pmax';-Pmin']
% Plims_size = size(Plims)
% b_reg = reshape(Plims,Plims_size(1)*Plims_size(2),1)








%%
clear all
num_time_steps=4
num_gens=2
cols=[]
for i=1:num_time_steps
   curr_a = (1:num_gens)+(i-1)*(2*num_gens+2) 
   cols = horzcat(cols,curr_a)
end

rows          = 1:(num_time_steps-1)*num_gens;
cols_2        = cols+(2*num_gens+2)
rows_odd_reg  = 1:2:2*num_gens*num_time_steps;
rows_even_reg = 2:2:2*num_gens*num_time_steps;
cols_reg_2    = cols + num_gens+2

A_ru  = sparse(rows,cols(rows),-1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_ru  = A_ru + sparse(rows,cols_2(rows),1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_rd  = sparse(rows,cols(rows),1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_rd  = A_rd + sparse(rows,cols_2(rows),-1,(num_time_steps-1)*num_gens,num_time_steps*(2*num_gens+2));
A_reg = sparse(rows_odd_reg,cols,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_odd_reg,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_even_reg,cols,-1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
A_reg = A_reg + sparse(rows_even_reg,cols_reg_2,1,2*num_gens*num_time_steps,num_time_steps*(2*num_gens+2));
 
A = [A_ru;A_rd;A_reg];






