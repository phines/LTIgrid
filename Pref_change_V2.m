function [ Pref ] = Pref_change_V2( Pref_current, Pref_next, t_span,t_curr )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

t_span_fifth=(t_span(2)-t_span(1))/5; %TO DO ONE EVERY MINUTE NEED TO DIVIDE BY DISP_T (but should be do it the same amount of oftenness?)
t_range = t_span(1):t_span_fifth:t_span(2);
delta_Pref_fifth = (Pref_next-Pref_current)/5;
half_range = (t_range(2)-t_range(1))/2;
for i=1:length(Pref_current)
     if delta_Pref_fifth(i)==0
         Pref_range(:,i)= Pref_current(i)*ones(6,1)
     else 
         Pref_range(:,i) = Pref_current(i):delta_Pref_fifth(i):Pref_next(i);
     end

end

if t_curr<t_range(1)+half_range
    Pref=Pref_range(1,:);
elseif t_curr<t_range(2)+half_range
    Pref=Pref_range(2,:);
elseif t_curr<t_range(3)+half_range
    Pref=Pref_range(3,:);
elseif t_curr<t_range(4)+half_range
    Pref=Pref_range(4,:);
elseif t_curr<t_range(5)+half_range
    Pref=Pref_range(5,:);
elseif t_curr<t_range(6)+half_range
    Pref=Pref_range(6,:);
end

Pref=Pref';
end

