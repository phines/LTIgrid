function [ACE,CPS1_scores,CPS2_scores,CPS1,CPS2] = checkStandards_will(ps,omega,theta,t,epsilon_1)
% usage: [ACE,CPS1_scores,CPS2_scores] = checkStandards(ps,omega,theta,t)

% get index
nmacs = size(ps.mac,1);
n     = size(ps.bus,1);
ix    = get_indices_will(n,nmacs);

% constants
sec_per_min = 60;

% extract data from ps
B_pu  = ps.areas(:,2);
B     = B_pu*ps.baseMVA/ps.frequency;
nA = length(ps.tie_lines_F);

% initialize outputs
ACE_pu = zeros(length(t),nA);
x   = zeros(ix.nx,1);
omega_pu = omega/ps.frequency/2/pi;%LIBBY ADDED THIS

for i = 1:length(ACE_pu)    
    x(ix.x.omega) = omega_pu(i,:);
    y = theta(i,:)';
    ACE_pu(i,:) = get_ACE_temp(x,y,ps,0);
end


%ACE=ACE_pu
ACE = ACE_pu*ps.baseMVA; % convert to MW
interconnect_omega = mean(omega,2)/2/pi - ps.frequency; % convert to Hz

% setup time steps for CPS values
nt_NERC = length(ACE);
n_steps_per_10min = 10*sec_per_min; % number of steps per 10 minute period
n_steps_per_min = sec_per_min;      % number of steps per minute

% intialize step sizes for CPS values
n_CPS1_steps = nt_NERC/n_steps_per_min;
n_CPS2_steps = nt_NERC/n_steps_per_10min;

% intialize outputs
CPS1_scores = zeros(n_CPS1_steps,nA);
CPS2_scores = zeros(n_CPS2_steps,nA);

for i = 1:nA
    % test CPS1
    for N = 1:n_CPS1_steps
        kappa_1 = (1:n_steps_per_min) + (N-1)*n_steps_per_min;
        CPS1_scores(N,i) = mean(ACE(kappa_1,i))/B(i) * mean(interconnect_omega(kappa_1));
    end

    % test CPS2
    for N = 1:n_CPS2_steps
        kappa_2 = (1:n_steps_per_10min) + (N-1)*n_steps_per_10min;
        CPS2_scores(N,i) = mean(abs(ACE(kappa_2,i)));
    end
end

% CPS1

L10 = 50;
CF   = mean(abs(CPS1_scores))/epsilon_1^2;
CPS1 = (2 - CF)*100

% CPS2
violations_1 = length(find(CPS2_scores(:,1)>=L10));
violations_2 = length(find(CPS2_scores(:,2)>=L10));
CPS2 = [(1 - (violations_1/length(CPS2_scores)))*100 (1 - (violations_2/length(CPS2_scores)))*100]


