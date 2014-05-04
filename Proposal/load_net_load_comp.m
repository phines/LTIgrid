

%% CCDF
BPA_Wind_Gen=[];
BPA_Var=[];

for i=1:4
    file_num                  = 2006+i;
    file_num_str              = num2str(file_num);
    file_name                 = strcat('BPA_TotalWindLoad_5Min_',file_num_str,'.csv');
    Curr_BPA                  = importdata(file_name);
    Curr_Gen                  = Curr_BPA.data(:,1);
    Curr_Gen(isnan(Curr_Gen)) = [];
    BPA_Wind_Gen              = vertcat(BPA_Wind_Gen,Curr_Gen);
    Curr_Var                  = Curr_Gen(2:end)-Curr_Gen(1:end-1);
    BPA_Var                   = vertcat(BPA_Var,Curr_Var);
end
NE_data   = importdata('ISO-NewEngland 5 Minute Total Load.csv');
NE_Load   = NE_data.data(:,7);
Load_Var  = NE_Load(2:end)-NE_Load(1:end-1);

%% get single ccdfs
BPA_Wind_Gen(isnan(BPA_Wind_Gen))=[];

BPA_Var      = BPA_Var/max(BPA_Wind_Gen);
[P_BPA,X]    = empirical_ccdf_v2(BPA_Var);

Load_Var      = Load_Var/max(NE_Load);
[P_NELOAD,X2] = empirical_ccdf_v2(Load_Var);

%% get net load
load_avg_total      = mean(NE_Load(:,end));      % avg load for the entire length of time
load_10p            = 0.1*load_avg_total;
load_20p            = 0.2*load_avg_total;
load_40p            = 0.4*load_avg_total;

BPA_subset        = BPA_Wind_Gen(1:length(NE_Load));
BPA_avg           = mean(BPA_subset);
scale_10p         = load_10p/BPA_avg;
scale_20p         = load_20p/BPA_avg;
scale_40p         = load_40p/BPA_avg;

Net_Load_10p          = NE_Load-scale_10p*BPA_subset;
Net_Load_20p          = NE_Load-scale_20p*BPA_subset;
Net_Load_40p          = NE_Load-scale_40p*BPA_subset;

Net_Load_Var_10p      = Net_Load_10p(2:end)-Net_Load_10p(1:end-1);
Net_Load_Var_10p      = Net_Load_Var_10p/max(Net_Load_10p);
Net_Load_Var_20p      = Net_Load_20p(2:end)-Net_Load_20p(1:end-1);
Net_Load_Var_20p      = Net_Load_Var_20p/max(Net_Load_20p);
Net_Load_Var_40p      = Net_Load_40p(2:end)-Net_Load_40p(1:end-1);
Net_Load_Var_40p      = Net_Load_Var_40p/max(Net_Load_40p);

[P_NetLoad_10p,X_10p]    = empirical_ccdf_v2(Net_Load_Var_10p);
[P_NetLoad_20p,X_20p]    = empirical_ccdf_v2(Net_Load_Var_20p);
[P_NetLoad_40p,X_40p]    = empirical_ccdf_v2(Net_Load_Var_40p);
% %% figure
% figure(5);clf;
% set(gca,'fontsize',25)
% semilogy(X,P_BPA,'k','linewidth',1.5)
% hold on;
% semilogy(X,2*(1-P_BPA_Gauss),'r--','linewidth',1.5)
% %events=[1/6,1/144,1/1008,1/4320,1/52560,1/525600];
% %plot(.26,events,'om')
% width=2;
% annotation('line',[.895,.915],[0.824,0.824],'linewidth',width) %these aren't in the right location without properly sized plot
% annotation('line',[.895,.915],[.644,.644],'linewidth',width) %uncomment "events" to get correct location
% annotation('line',[.895,.915],[.534,.534],'linewidth',width)
% annotation('line',[.895,.915],[.453,.453],'linewidth',width)
% annotation('line',[.895,.915],[.309,.309],'linewidth',width)
% annotation('line',[.895,.915],[.178,.178],'linewidth',width)
% annotation('textbox',[.918,.827,.1,.04],'String','1/hour','linestyle','none','fontsize',24)
% annotation('textbox',[.918,.647,.1,.04],'String','1/day','linestyle','none','fontsize',24)
% annotation('textbox',[.918,.537,.1,.04],'String','1/week','linestyle','none','fontsize',24)
% annotation('textbox',[.918,.456,.1,.04],'String','1/month','linestyle','none','fontsize',24)
% annotation('textbox',[.918,.312,.1,.04],'String','1/year','linestyle','none','fontsize',24)
% annotation('textbox',[.918,.198,.1,.04],'String','1/10 years','linestyle','none','fontsize',24)
% axis([-0.0003,.2601,10.0001^-6,1])
% set(gca,'ytick',[1e-6 1e-4 1e-2 1e0 1e1])
% xlabel('Change in Power (Percent of Capacity)','fontsize',24)
% ylabel('Probability','fontsize',24)
% legend('Empirical','Gaussian','Location',[.75 .73 .12 .12])
% legend('boxoff')
%%
figure(1);clf;hold on
%semilogy(X,P_BPA,'k','linewidth',1.5)
semilogy(X2,P_NELOAD,'r','linewidth',1.5)
semilogy(X_10p,P_NetLoad_10p,'b','linewidth',1.5)
semilogy(X_20p,P_NetLoad_20p,'g','linewidth',1.5)
semilogy(X_40p,P_NetLoad_40p,'m','linewidth',1.5)
semilogy(0.1,5e-4,'ro')
ylabel('Probability')
xlabel('Change in Power in 5 Minutes')
legend('Total Load','Net Load, 10% Wind','Net Load, 20% Wind','Net Load, 40% Wind')