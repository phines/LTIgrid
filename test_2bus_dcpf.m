C=psconstants_will
ps = case2_ps; % get the real one? K SHOULD BE 0.151, CHECK IT
ps = updateps(ps);
ps=dcpf(ps);

x=[0;0;1;1;0;0;0;0];
y=ps.bus(:,C.bu.Vang)*pi/180

ps       = find_areas(ps);
ACE = get_ACE_temp(x,y,ps)