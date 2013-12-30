function [value,isterminal,direction] = SwingEvents(t,~)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if t<1.001
    value = t-1;
else 
    value=t-1.1;
end

isterminal=0;
direction=1;
end

