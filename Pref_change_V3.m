function [ Pref ] = Pref_change_V3( Pref_current, Pref_next, t_span,t_curr )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
Pref=zeros(length(Pref_current),1);
for i = 1:length(Pref_current)
    Pref(i)=interp1(t_span,[Pref_current(i),Pref_next(i)],t_curr);
end