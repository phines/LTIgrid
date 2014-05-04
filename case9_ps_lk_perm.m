function ps = case9_ps_lk_perm

ps.baseMVA = 100.000000;
ps.frequency = 60;
omega_0 = 2*pi*ps.frequency;

ps.bus = [...
%ID type Pd Qd Gs Bs area Vmag Vang basekV zone Vmax Vmin lam_P lam_Q mu_Vx mu_Vn locX locY 
 1 3 0 0 0 0 2 1.04 0 16.5 1 1.1 0.9 0 0 0 0 0 0;
 2 2 0 0 0 0 1 1.025 0 16.5 1 1.1 0.9 0 0 0 0 0 0;
 3 2 0 0 0 0 1 1.025 0 16.5 1 1.1 0.9 0 0 0 0 0 0;
 4 1 0 0 0 0 2 1 0 230 1 1.1 0.9 0 0 0 0 0 0;
 5 1 0 0 0 0 2 1 0 230 1 1.1 0.9 0 0 0 0 0 0;
 6 1 0 0 0 0 2 1 0 230 1 1.1 0.9 0 0 0 0 0 0;
 7 1 0 0 0 0 1 1 0 230 1 1.1 0.9 0 0 0 0 0 0;
 8 1 0 0 0 0 1 1 0 230 1 1.1 0.9 0 0 0 0 0 0;
 9 1 0 0 0 0 1 1 0 230 1 1.1 0.9 0 0 0 0 0 0;
];

ps.branch = [...
%from to R X B rateA rateB rateC tap shift status 
 1 4 0 0.0576 0 250 250 250 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 2 7 0 0.0625 0 250 250 250 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 3 9 0 0.0586 0 300 300 300 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 4 5 0.01 0.085 0.176 250 250 250 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 4 6 0.017 0.092 0.158 250 250 250 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 5 7 0.032 0.161 0.306 250 250 250 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 6 9 0.039 0.17 0.358 150 150 150 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 7 8 0.0085 0.072 0.149 250 250 250 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 8 9 0.0119 0.1008 0.209 150 150 150 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
];

ps.gen = [...
%bus Pg Qg Qmax Qmin Vsp mBase status Pmax Pmin mu_Px mu_Pn mu_Qx mu_Qn type cost 
 1 210 80 300 -300 1.04 100 1 250 10 0 0 0 0 3 5 1;
 2 75  10 300 -300 1.025 100 1 300 10 0 0 0 0 2 1.2 0;
 3 25  10 300 -300 1.025 100 1 270 10 0 0 0 0 2 1 0;
];

ps.shunt = [...
%bus P Q frac_S frac_Z status type value 
 5 125 50 1 0 1 1 1000 0; %125 normally
 6  90 30 1 0 1 1 1000 0;
 8 100 35 1 0 1 1 1000 0;
];

ps.mac = [...
%gen r Xd Xdp Xdpp Xq Xqp Xqpp D M Ea Eap Pm delta omega P1 delta bus time label  Tg Tt k(R) Pc 
 1 0 0.1460 0.0608 0 0 0 0 0 47.28 1.2 0 0 0 omega_0 0 0 0 0 0 1 0 0.05; %added Tg values and R values
 2 0 0.8958 0.1198 0 0 0 0 0 12.8 1.2 0 0 0 omega_0 0 0 0 0 0 1.2 0 0.05;
 3 0 1.3125 0.1813 0 0 0 0 0 6.02 1.2 0 0 0 omega_0 0 0 0 0 0  1 0 0.05;    
];
ps.mac(:,6:8) = ps.mac(:,3:5)*0.8; %what does this do?

% set the damping constant for the machines
M = ps.mac(:,10);
ps.mac(:,9) =  M/2;

ps.areas = [...
 0.151 5;
 0.151 5;
];

ps.gencost = [...
 2 1500 0 3 0.11 5 150;
 2 2000 0 3 0.085 1.2 600;
 2 3000 0 3 0.1225 1 335;
];

ps.gov = [...
%gen Type  R    Tg   LCmax  LCmin  Pmax  Pmin  Pref
 1    1   0.05  1.2    1     -1     2.5   0     0
 2    1   0.05  1.0    1     -1     3.0   0     0
 3    1   0.05  1.0    1     -1     2.7   0     0
];
