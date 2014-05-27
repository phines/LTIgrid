clc
clear all
t_span=[300,600]
Pref_current = 100
Pref_next = 110
for t =300:600
     Prefcheck(t-299,:)= Pref_change_V2( Pref_current, Pref_next, t_span,t );
end
ts=300:600
figure;
plot(ts,Prefcheck)