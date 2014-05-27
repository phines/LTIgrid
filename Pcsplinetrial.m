function [ delta_Pc_dot_lim ] = Pcsplinetrial( delta_Pc,delta_Pc_dot,Reg_up,Reg_down )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here


if delta_Pc>Reg_up
    if delta_Pc_dot>0
        delta_Pc_dot_lim=0;
    else
        delta_Pc_dot_lim=delta_Pc_dot;
    end
elseif delta_Pc<Reg_down
    if delta_Pc_dot<0
        delta_Pc_dot_lim=0;
    else
        delta_Pc_dot_lim=delta_Pc_dot;
    end
else %delta_Pc is within its limits
    delta_Pc_dot_lim=delta_Pc_dot;
end


end

