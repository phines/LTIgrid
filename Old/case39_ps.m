function ps = case39_ps

ps.baseMVA = 100.000000;

ps.bus = [...
%ID type Pd Qd Gs Bs area Vmag Vang basekV zone Vmax Vmin lam_P lam_Q mu_Vx mu_Vn locX locY 
 1 1 0 0 0 0 1 1 0 230 1 1.06 0.94 0 0 0 0 0 0;
 2 1 0 0 0 0 1 1 0 230 1 1.06 0.94 0 0 0 0 0 0;
 3 1 0 0 0 0 1 1.0341 -9.73 230 1 1.06 0.94 0 0 0 0 0 0;
 4 1 0 0 0 0 1 1.0116 -10.53 230 1 1.06 0.94 0 0 0 0 0 0;
 5 1 0 0 0 0 1 1.0165 -9.38 230 1 1.06 0.94 0 0 0 0 0 0;
 6 1 0 0 0 0 1 1.0172 -8.68 230 1 1.06 0.94 0 0 0 0 0 0;
 7 1 0 0 0 0 1 1.0067 -10.84 230 1 1.06 0.94 0 0 0 0 0 0;
 8 1 0 0 0 0 1 1.0057 -11.34 230 1 1.06 0.94 0 0 0 0 0 0;
 9 1 0 0 0 0 1 1.0322 -11.15 230 1 1.06 0.94 0 0 0 0 0 0;
 10 1 0 0 0 0 1 1.0235 -6.31 230 1 1.06 0.94 0 0 0 0 0 0;
 11 1 0 0 0 0 1 1.0201 -7.12 230 1 1.06 0.94 0 0 0 0 0 0;
 12 1 0 0 0 0 1 1.0072 -7.14 230 1 1.06 0.94 0 0 0 0 0 0;
 13 1 0 0 0 0 1 1.0207 -7.02 230 1 1.06 0.94 0 0 0 0 0 0;
 14 1 0 0 0 0 1 1.0181 -8.66 230 1 1.06 0.94 0 0 0 0 0 0;
 15 1 0 0 0 0 1 1.0194 -9.06 230 1 1.06 0.94 0 0 0 0 0 0;
 16 1 0 0 0 0 1 1.0346 -7.66 230 1 1.06 0.94 0 0 0 0 0 0;
 17 1 0 0 0 0 1 1.0365 -8.65 230 1 1.06 0.94 0 0 0 0 0 0;
 18 1 0 0 0 0 1 1.0343 -9.49 230 1 1.06 0.94 0 0 0 0 0 0;
 19 1 0 0 0 0 1 1.0509 -3.04 230 1 1.06 0.94 0 0 0 0 0 0;
 20 1 0 0 0 0 1 0.9914 -4.45 230 1 1.06 0.94 0 0 0 0 0 0;
 21 1 0 0 0 0 1 1.0337 -5.26 230 1 1.06 0.94 0 0 0 0 0 0;
 22 1 0 0 0 0 1 1.0509 -0.82 230 1 1.06 0.94 0 0 0 0 0 0;
 23 1 0 0 0 0 1 1.0459 -1.02 230 1 1.06 0.94 0 0 0 0 0 0;
 24 1 0 0 0 0 1 1.0399 -7.54 230 1 1.06 0.94 0 0 0 0 0 0;
 25 1 0 0 0 0 1 1.0587 -5.51 230 1 1.06 0.94 0 0 0 0 0 0;
 26 1 0 0 0 0 1 1.0536 -6.77 230 1 1.06 0.94 0 0 0 0 0 0;
 27 1 0 0 0 0 1 1.0399 -8.78 230 1 1.06 0.94 0 0 0 0 0 0;
 28 1 0 0 0 0 1 1.0509 -3.27 230 1 1.06 0.94 0 0 0 0 0 0;
 29 1 0 0 0 0 1 1.0505 -0.51 230 1 1.06 0.94 0 0 0 0 0 0;
 30 2 0 0 0 0 1 1.0475 0 230 1 1.06 0.94 0 0 0 0 0 0;
 31 3 0 0 0 0 1 0.982 0 230 1 1.06 0.94 0 0 0 0 0 0;
 32 2 0 0 0 0 1 0.9831 1.63 230 1 1.06 0.94 0 0 0 0 0 0;
 33 2 0 0 0 0 1 0.9972 2.18 230 1 1.06 0.94 0 0 0 0 0 0;
 34 2 0 0 0 0 1 1.0123 0.74 230 1 1.06 0.94 0 0 0 0 0 0;
 35 2 0 0 0 0 1 1.0493 4.14 230 1 1.06 0.94 0 0 0 0 0 0;
 36 2 0 0 0 0 1 1.0635 6.83 230 1 1.06 0.94 0 0 0 0 0 0;
 37 2 0 0 0 0 1 1.0278 1.27 230 1 1.06 0.94 0 0 0 0 0 0;
 38 2 0 0 0 0 1 1.0265 6.55 230 1 1.06 0.94 0 0 0 0 0 0;
 39 2 0 0 0 0 1 1.03 -10.96 230 1 1.06 0.94 0 0 0 0 0 0;
];

ps.branch = [...
%from to R X B rateA rateB rateC tap shift status 
 1 2 0.0035 0.0411 0.6987 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 1 39 0.001 0.025 0.75 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 2 3 0.0013 0.0151 0.2572 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 2 25 0.007 0.0086 0.146 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 3 4 0.0013 0.0213 0.2214 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 3 18 0.0011 0.0133 0.2138 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 4 5 0.0008 0.0128 0.1342 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 4 14 0.0008 0.0129 0.1382 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 5 6 0.0002 0.0026 0.0434 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 5 8 0.0008 0.0112 0.1476 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 6 7 0.0006 0.0092 0.113 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 6 11 0.0007 0.0082 0.1389 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 7 8 0.0004 0.0046 0.078 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 8 9 0.0023 0.0363 0.3804 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 9 39 0.001 0.025 1.2 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 10 11 0.0004 0.0043 0.0729 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 10 13 0.0004 0.0043 0.0729 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 13 14 0.0009 0.0101 0.1723 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 14 15 0.0018 0.0217 0.366 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 15 16 0.0009 0.0094 0.171 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 16 17 0.0007 0.0089 0.1342 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 16 19 0.0016 0.0195 0.304 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 16 21 0.0008 0.0135 0.2548 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 16 24 0.0003 0.0059 0.068 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 17 18 0.0007 0.0082 0.1319 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 17 27 0.0013 0.0173 0.3216 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 21 22 0.0008 0.014 0.2565 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 22 23 0.0006 0.0096 0.1846 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 23 24 0.0022 0.035 0.361 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 25 26 0.0032 0.0323 0.513 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 26 27 0.0014 0.0147 0.2396 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 26 28 0.0043 0.0474 0.7802 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 26 29 0.0057 0.0625 1.029 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 28 29 0.0014 0.0151 0.249 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 12 11 0.0016 0.0435 0 9900 0 0 1.006 0 1 0 0 0 0 0 0 0 0 0 0 0;
 12 13 0.0016 0.0435 0 9900 0 0 1.006 0 1 0 0 0 0 0 0 0 0 0 0 0;
 6 31 0 0.025 0 9900 0 0 1.07 0 1 0 0 0 0 0 0 0 0 0 0 0;
 10 32 0 0.02 0 9900 0 0 1.07 0 1 0 0 0 0 0 0 0 0 0 0 0;
 19 33 0.0007 0.0142 0 9900 0 0 1.07 0 1 0 0 0 0 0 0 0 0 0 0 0;
 20 34 0.0009 0.018 0 9900 0 0 1.009 0 1 0 0 0 0 0 0 0 0 0 0 0;
 22 35 0 0.0143 0 9900 0 0 1.025 0 1 0 0 0 0 0 0 0 0 0 0 0;
 23 36 0.0005 0.0272 0 9900 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0;
 25 37 0.0006 0.0232 0 9900 0 0 1.025 0 1 0 0 0 0 0 0 0 0 0 0 0;
 2 30 0 0.0181 0 9900 0 0 1.025 0 1 0 0 0 0 0 0 0 0 0 0 0;
 29 38 0.0008 0.0156 0 9900 0 0 1.025 0 1 0 0 0 0 0 0 0 0 0 0 0;
 19 20 0.0007 0.0138 0 9900 0 0 1.06 0 1 0 0 0 0 0 0 0 0 0 0 0;
];


ps.gen = [...
%bus Pg Qg Qmax Qmin Vsp mBase status Pmax Pmin mu_Px mu_Pn mu_Qx mu_Qn type cost 
 39 1000 68.5 9999 -9999 1.03 100 1 1100 0 0 0 0 0 2 0.3 0;
 31 572.9 170.3 9999 -9999 0.982 100 1 1145.55 0 0 0 0 0 3 0.3 1;
 32 650 175.9 9999 -9999 0.9831 100 1 750 0 0 0 0 0 2 0.3 0;
 33 632 103.3 9999 -9999 0.9972 100 1 732 0 0 0 0 0 2 0.3 0;
 34 508 164.4 9999 -9999 1.0123 100 1 608 0 0 0 0 0 2 0.3 0;
 35 650 204.8 9999 -9999 1.0493 100 1 750 0 0 0 0 0 2 0.3 0;
 36 560 96.9 9999 -9999 1.0635 100 1 660 0 0 0 0 0 2 0.3 0;
 37 540 -4.4 9999 -9999 1.0278 100 1 640 0 0 0 0 0 2 0.3 0;
 38 830 19.4 9999 -9999 1.0265 100 1 930 0 0 0 0 0 2 0.3 0;
 30 250 103.3 9999 -9999 1.0475 100 1 350 0 0 0 0 0 2 0.3 0;
];

ps.shunt = [...
%bus P Q frac_S frac_Z status type value 
 3 322 2.4 1 0 1 1 1000 0;
 4 500 184 1 0 1 1 1000 0;
 7 233.8 84 1 0 1 1 1000 0;
 8 522 176.6 1 0 1 1 1000 0;
 12 8.5 88 1 0 1 1 1000 0;
 15 320 153 1 0 1 1 1000 0;
 16 329.4 32.3 1 0 1 1 1000 0;
 18 158 30 1 0 1 1 1000 0;
 20 680 103 1 0 1 1 1000 0;
 21 274 115 1 0 1 1 1000 0;
 23 247.5 84.6 1 0 1 1 1000 0;
 24 308.6 -92.2 1 0 1 1 1000 0;
 25 224 47.2 1 0 1 1 1000 0;
 26 139 17 1 0 1 1 1000 0;
 27 281 75.5 1 0 1 1 1000 0;
 28 206 27.6 1 0 1 1 1000 0;
 29 283.5 26.9 1 0 1 1 1000 0;
 31 9.2 4.6 1 0 1 1 1000 0;
 39 1104 250 1 0 1 1 1000 0;
];

ps.mac = [...
%gen r Xd Xdp Xdpp Xq Xqp Xqpp D M Ea Eap Pm delta omega
 39 0 0.0200 0.0060 0 0.0190 0.0080 0 0 1000 1.2 0 0 0 0;
 31 0 0.2950 0.0697 0 0.2820 0.1700 0 0 60.6 1.2 0 0 0 0;
 32 0 0.2495 0.0531 0 0.2370 0.0876 0 0 71.6 1.2 0 0 0 0;
 33 0 0.2620 0.0436 0 0.2580 0.1660 0 0 57.2 1.2 0 0 0 0;
 34 0 0.6700 0.1320 0 0.6200 0.1660 0 0 52.0 1.2 0 0 0 0;
 35 0 0.2540 0.0500 0 0.2410 0.0814 0 0 69.6 1.2 0 0 0 0;
 36 0 0.2950 0.0490 0 0.2920 0.1860 0 0 52.8 1.2 0 0 0 0;
 37 0 0.2900 0.0570 0 0.2800 0.0911 0 0 48.6 1.2 0 0 0 0;
 38 0 0.2106 0.0570 0 0.2050 0.0587 0 0 69.0 1.2 0 0 0 0;
 30 0 0.1000 0.0310 0 0.0690 0.0080 0 0 84.0 1.2 0 0 0 0;
];
% set the damping constant for the machines
M = ps.mac(:,10);
ps.mac(:,9) =  M/2;


ps.areas = [...
 1 1;
];

ps.gencost = [...
 2 0 0 3 0.01 0.3 0.2;
 2 0 0 3 0.01 0.3 0.2;
 2 0 0 3 0.01 0.3 0.2;
 2 0 0 3 0.01 0.3 0.2;
 2 0 0 3 0.01 0.3 0.2;
 2 0 0 3 0.01 0.3 0.2;
 2 0 0 3 0.01 0.3 0.2;
 2 0 0 3 0.01 0.3 0.2;
 2 0 0 3 0.006 0.3 0.2;
 2 0 0 3 0.006 0.3 0.2;
];
