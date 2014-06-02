function [delta_Pc_dot_lim,dPcdotlim_dPcdotomega,dPcdotlim_dPcdotPc,dPcdotlim_dPcdottheta] = Pcsplinetrial_V3( delta_Pc,delta_Pc_dot,Reg_up,Reg_down)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

nmacs = length(delta_Pc);
delta_Pc_dot_lim = zeros(nmacs,1);
dPcdotlim_dPcdot = zeros(nmacs,1);
for i=1:nmacs
    if delta_Pc_dot(i)<0
        if delta_Pc(i) < Reg_down(i)
            delta_Pc_dot_lim(i)=0;
            % dPcdotlim_dPcdot(i)=0;
            dPcdotlim_dPcdotomega(i)=0;
            dPcdotlim_dPcdotPc(i)=0;
            dPcdotlim_dPcdottheta(i)=0;
        elseif delta_Pc(i) >= Reg_down(i) && delta_Pc(i) < Reg_down(i)*.9
            [delta_Pc_dot_lim_curr,dPcdotlim_dPcdotomega_curr ]= sigm_fn(delta_Pc_dot(i),Reg_down(i),delta_Pc(i));
            delta_Pc_dot_lim(i) = delta_Pc_dot_lim_curr;
            dPcdotlim_dPcdotomega(i)=dPcdotlim_dPcdotomega_curr;
            dPcdotlim_dPcdotPc(i)=1;
            dPcdotlim_dPcdottheta(i)=1;
            %keyboard
        else
            delta_Pc_dot_lim(i)=delta_Pc_dot(i);
            dPcdotlim_dPcdotomega(i)=1;
            dPcdotlim_dPcdotPc(i)=0;
            dPcdotlim_dPcdottheta(i)=1;
        end
    elseif delta_Pc_dot(i)>0
        if delta_Pc(i) > Reg_up(i)
            delta_Pc_dot_lim(i)=0;
            %dPcdotlim_dPcdot(i)=0;
            dPcdotlim_dPcdotomega(i)=0;
            dPcdotlim_dPcdotPc(i)=0;
            dPcdotlim_dPcdottheta(i)=0;
        elseif delta_Pc(i) <= Reg_up(i) && delta_Pc(i) > Reg_up(i)*0.9
            delta_Pc_dot_lim(i) = sigm_fn(delta_Pc_dot(i),Reg_up(i),delta_Pc(i));
            dPcdotlim_dPcdotomega(i)=1;
            dPcdotlim_dPcdotPc(i)=1;
            dPcdotlim_dPcdottheta(i)=1;
            % keyboard
        else
            delta_Pc_dot_lim(i)=delta_Pc_dot(i);
            dPcdotlim_dPcdotomega(i)=1;
            dPcdotlim_dPcdotPc(i)=0;
            dPcdotlim_dPcdottheta(i)=1;
        end
    else
        delta_Pc_dot_lim(i)=delta_Pc_dot(i);
        dPcdotlim_dPcdotomega(i)=1;
        dPcdotlim_dPcdotPc(i)=0;
        dPcdotlim_dPcdottheta(i)=1;
    end
end


end

