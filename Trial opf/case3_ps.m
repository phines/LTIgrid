function ps = case3_ps
% Libby's 3 bus test case

ps.baseMVA = 100;

ps.bus = [
    %bus_i type	Pd     Qd   Gs  Bs	area  Vm         Va         baseKV  zone  Vmax 	Vmin
       1	3	19.2   4.6   0	 0	  1	  0.982	      0	         345	 1    1.06	0.94;
       2	1	197.6  44.2  0	 0	  2	  1.0393836	 -13.536602	 345     1	  1.06	0.94;
       3	1	600	   184   0	 0	  1   1.00446	 -12.626734	 345	 1    1.06	0.94;
 ];

ps.gen = [
  %bus	Pg	    Qg	 Qmax	Qmin	Vg	   mBase  status  Pmax	Pmin  Pc1  Pc2  Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc  ramp_10  ramp_30	ramp_q  apf  5_min_ramp_rate
    1	150	    81.2  400	140	    1.0499	100	   1	  1040	 0     0	0	  0 	  0       0 	  0	        0	    0	      0	      0	     0      1040*1; %currently, ramprate=Pmax*1 (CCGas), see 'set ramp rates.m' for others
	2	477.8  142.5  300	-100	0.982	100	   1	   646	 0	   0	0	  0	      0 	  0	      0	        0    	0	      0       0  	 0       646*1;
    ];

ps.branch = [
  %fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax

    1	2	0.0035	0.0411	0.6987	600	600	600	0	0	1	-360	360;
	1	3	0.001	0.025	0.75	1000	1000	1000	0	0	1	-360	360;
	2	3	0.0013	0.0151	0.2572	500	500	500	0	0	1	-360	360;
    ];

ps.gencost = [
   %2	startup	shutdown	n	c(n-1)	...	c0
	2	0	0	3	0.01	2.7	0.2; %randomly changed 0.3s to 1.3 and 1.6
	2	0	0	3	0.01	1.3	0.2;
    ];