function ps = set_ramp_rates(ps)

C = psconstants_will;

loc_nuc   = ps.gen(:,C.ge.gen_type)==1; %SHOULD BE GENTYPE NOT TYPE? - changed
loc_coal  = ps.gen(:,C.ge.gen_type)==2;   
loc_cc    = ps.gen(:,C.ge.gen_type)==3;
loc_sc    = ps.gen(:,C.ge.gen_type)==4;
loc_oil   = ps.gen(:,C.ge.gen_type)==5;


%%where do the scaling factors applied come from?
a=5
% set nuclear ramp limits
ps.gen(loc_nuc,C.ge.ramp_rate_up)   = +ps.gen(loc_nuc,C.ge.Pmax)*0.1*a;
ps.gen(loc_nuc,C.ge.ramp_rate_down) = -ps.gen(loc_nuc,C.ge.Pmax)*0.1*a;
ps.gov(loc_nuc,C.gov.LCmax)         = +ps.gen(loc_nuc,C.ge.Pmax)*0.1*a/ps.baseMVA/3600 %(was 10% of Mw/hr, now 10% of pu/s)
ps.gov(loc_nuc,C.gov.LCmin)         = -ps.gen(loc_nuc,C.ge.Pmax)*0.1*a/ps.baseMVA/3600 %(was 10% of Mw/hr, now 10% of pu/s)

% set coal ramp limits
ps.gen(loc_coal,C.ge.ramp_rate_up)   = +ps.gen(loc_coal,C.ge.Pmax)*0.3*a;
ps.gen(loc_coal,C.ge.ramp_rate_down) = -ps.gen(loc_coal,C.ge.Pmax)*0.3*a;
ps.gov(loc_coal,C.gov.LCmax)         = +ps.gen(loc_coal,C.ge.Pmax)*0.3*a/ps.baseMVA/3600 %(was 30% of Mw/hr, now 30% of pu/s)
ps.gov(loc_coal,C.gov.LCmin)         = -ps.gen(loc_coal,C.ge.Pmax)*0.3*a/ps.baseMVA/3600 %(was 30% of Mw/hr, now 30% of pu/s)

% set CC Gas ramp limits
ps.gen(loc_cc,C.ge.ramp_rate_up)   = +ps.gen(loc_cc,C.ge.Pmax)*1*a;
ps.gen(loc_cc,C.ge.ramp_rate_down) = -ps.gen(loc_cc,C.ge.Pmax)*1*a;
ps.gov(loc_cc,C.gov.LCmax)         = +ps.gen(loc_cc,C.ge.Pmax)*1*a/ps.baseMVA/3600 %(was 100% of Mw/hr, now 100% of pu/s)
ps.gov(loc_cc,C.gov.LCmin)         = -ps.gen(loc_cc,C.ge.Pmax)*1*a/ps.baseMVA/3600 %(was 100% of Mw/hr, now 100% of pu/s)

% set SC Gas ramp limits
ps.gen(loc_sc,C.ge.ramp_rate_up)   = +ps.gen(loc_sc,C.ge.Pmax)*3*a%6; i think thiss should be 3 not 6 b/c 100%/20min not /10min
ps.gen(loc_sc,C.ge.ramp_rate_down) = -ps.gen(loc_sc,C.ge.Pmax)*3*a%6;
ps.gov(loc_sc,C.gov.LCmax)         = +ps.gen(loc_sc,C.ge.Pmax)*3*a/ps.baseMVA/(20*60) %(was 100% of Mw/20min, now pu/s-->100%*MW/20min/baseMVA=100%*pu/20min*(1min/60s=pu/s)
ps.gov(loc_sc,C.gov.LCmin)         = -ps.gen(loc_sc,C.ge.Pmax)*3*a/ps.baseMVA/(20*60) %(was 100% of Mw/20min, now pu/s)
%above is equivalent to Pmax*3/baseMVA/3600 which is good!

% set Oil ramp limits
ps.gen(loc_oil,C.ge.ramp_rate_up)   = +ps.gen(loc_oil,C.ge.Pmax)*3*a%6;
ps.gen(loc_oil,C.ge.ramp_rate_down) = -ps.gen(loc_oil,C.ge.Pmax)*3*a%6;
ps.gov(loc_oil,C.gov.LCmax)         = +ps.gen(loc_oil,C.ge.Pmax)*3*a/ps.baseMVA/(20*60) %(was 100% of Mw/20min, now pu/s-->100%*MW/20min/baseMVA=100%*pu/20min*(1min/60s=pu/s)
ps.gov(loc_oil,C.gov.LCmin)         = -ps.gen(loc_oil,C.ge.Pmax)*3*a/ps.baseMVA/(20*60) %(was 100% of Mw/20min, now pu/s)

