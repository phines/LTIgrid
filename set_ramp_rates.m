function ps = set_ramp_rates(ps)

C = psconstants_will;

loc_nuc   = ps.gen(:,C.ge.type)==1;
loc_coal  = ps.gen(:,C.ge.type)==2;   
loc_cc    = ps.gen(:,C.ge.type)==3;
loc_sc    = ps.gen(:,C.ge.type)==4;
loc_oil   = ps.gen(:,C.ge.type)==5;


%%where do the scaling factors applied come from?

% set nuclear ramp limits
ps.gen(loc_nuc,C.ge.ramp_rate_up)   = +ps.gen(loc_nuc,C.ge.Pmax)*0.1;
ps.gen(loc_nuc,C.ge.ramp_rate_down) = -ps.gen(loc_nuc,C.ge.Pmax)*0.1;

% set coal ramp limits
ps.gen(loc_coal,C.ge.ramp_rate_up)   = +ps.gen(loc_coal,C.ge.Pmax)*0.3;
ps.gen(loc_coal,C.ge.ramp_rate_down) = -ps.gen(loc_coal,C.ge.Pmax)*0.3;

% set CC Gas ramp limits
ps.gen(loc_cc,C.ge.ramp_rate_up)   = +ps.gen(loc_cc,C.ge.Pmax)*1;
ps.gen(loc_cc,C.ge.ramp_rate_down) = -ps.gen(loc_cc,C.ge.Pmax)*1;

% set SC Gas ramp limits
ps.gen(loc_sc,C.ge.ramp_rate_up)   = +ps.gen(loc_sc,C.ge.Pmax)*6;
ps.gen(loc_sc,C.ge.ramp_rate_down) = -ps.gen(loc_sc,C.ge.Pmax)*6;

% set Oil ramp limits
ps.gen(loc_oil,C.ge.ramp_rate_up)   = +ps.gen(loc_oil,C.ge.Pmax)*6;
ps.gen(loc_oil,C.ge.ramp_rate_down) = -ps.gen(loc_oil,C.ge.Pmax)*6;