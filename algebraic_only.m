function [g,dg_dy] = algebraic_only(t,x,y,ps)

[g,~,dg_dy] = algebraic_eqs(t,x,y,ps);

