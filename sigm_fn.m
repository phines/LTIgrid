function [ delta_Pc_dot_lim,Jacb_scale_omega,Jacb_scale_Pc,Jacb_scale_theta ] = sigm_fn( delta_Pc_dot,Reg_bound,delta_Pc )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


%delta_Pc=0:.01:120;
C = 1000/abs(Reg_bound); %growth rate
Q = 1; %depends on the value of Y(0)
v = 1; %>0 affects near which asymptote maximum growth occurs
M = 0;

delta_Pc_vec = -abs(Reg_bound)*1.5:abs(Reg_bound)/100000:abs(Reg_bound)*1.5;
if delta_Pc_dot>0
    A                    = delta_Pc_dot; %lower asymptote
    K                    = 0; %upper asymptote
    delta_Pc_dot_lim_vec = A+(K-A)./((1+Q*exp(-C*(delta_Pc_vec-M))).^(1/v));
    a                    = find(delta_Pc_dot_lim_vec==K,1);
    tshift               = delta_Pc_vec(a);
    M                    = Reg_bound-tshift;  %time of maximum growth if Q=v (horizontal shift)
    delta_Pc_dot_lim_vec = A+(K-A)./((1+Q*exp(-C*(delta_Pc_vec-M))).^(1/v));
    b                    = find(delta_Pc_dot_lim_vec==A,1,'last');
    c                    = find(delta_Pc_dot_lim_vec==K,1);
    delta_Pc_vec         = delta_Pc_vec(b:c);
    delta_Pc_dot_lim_vec = delta_Pc_dot_lim_vec(b:c);
    delta_Pc_dot_lim     = spline(delta_Pc_vec,delta_Pc_dot_lim_vec,delta_Pc);
    Jacb_scale_omega     = 1+(1./(1+exp(-C.*(delta_Pc-M))));
    %Jacb_scale_Pc        = (-C*exp(-C*(delta_Pc_vec-M))*()))/((1+exp(-C*(delta_Pc_vec-M)))^2)
    Jacb_scale_theta     = 1+(-1./(1+exp(-C.*(delta_Pc-M))));
elseif delta_Pc_dot<0
    %delta_Pc=-110:.01:10;
    A                    = 0; %lower asymptote
    K                    = delta_Pc_dot; %upper asymptote
    delta_Pc_dot_lim_vec = A+(K-A)./((1+Q*exp(-C*(delta_Pc_vec-M))).^(1/v));
    a                    = find(delta_Pc_dot_lim_vec<A-1e-12,1);
    tshift               = delta_Pc_vec(a);
    M                    = Reg_bound-tshift;  %time of maximum growth if Q=v (horizontal shift)
    delta_Pc_dot_lim_vec = A+(K-A)./((1+Q*exp(-C*(delta_Pc_vec-M))).^(1/v));
    b                    = find(delta_Pc_dot_lim_vec<A-1e-12,1);
    c                    = find(delta_Pc_dot_lim_vec==K,1);
    delta_Pc_vec         = delta_Pc_vec(b:c);
    delta_Pc_dot_lim_vec = delta_Pc_dot_lim_vec(b:c);
    delta_Pc_dot_lim     = spline(delta_Pc_vec,delta_Pc_dot_lim_vec,delta_Pc);
    Jacb_scale_omega     = 1./(1+exp(-C.*(delta_Pc-M)));
    %Jacb_scale_Pc        = (-C*exp(-C*(delta_Pc_vec-M))*()))/((1+exp(-C*(delta_Pc_vec-M)))^2)
    Jacb_scale_theta     = 1./(1+exp(-C.*(delta_Pc-M)));
end
end

