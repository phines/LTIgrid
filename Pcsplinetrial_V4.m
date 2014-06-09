function [delta_Pc_dot_lim,dPcdotlim_dPc,dPcdotlim_dPcdot] = Pcsplinetrial_V4( delta_Pc,delta_Pc_dot,Reg_up,Reg_down)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

global Pcdotlim_Ru_spline dPcdotlim_dPc_upsp dPcdotlim_dPcdot_upsp Pcdotlim_Rd_spline dPcdotlim_dPc_downsp dPcdotlim_dPcdot_downsp

nmacs = length(delta_Pc);
delta_Pc_dot_lim = zeros(nmacs,1);
dPcdotlim_dPcdot = zeros(nmacs,1);
dPcdotlim_dPc    = zeros(nmacs,1);

for i=1:nmacs
    if delta_Pc_dot(i)<0
        if delta_Pc(i) < Reg_down(i)
            delta_Pc_dot_lim(i) = 0;
            dPcdotlim_dPcdot(i) = 0;
            dPcdotlim_dPc(i)    = 0;
            
            
        elseif delta_Pc(i) >= Reg_down(i) && delta_Pc(i) < Reg_down(i)*.99
            
            delta_Pc_dot_lim_curr = delta_Pc_dot(i)*ppval(Pcdotlim_Rd_spline(i),delta_Pc(i)); 
            dPcdotlim_dPc_curr    = delta_Pc_dot(i)*ppval(dPcdotlim_dPc_downsp(i),delta_Pc(i));
            dPcdotlim_dPcdot_curr = ppval(dPcdotlim_dPcdot_downsp(i),delta_Pc(i));
            
            delta_Pc_dot_lim(i)   = delta_Pc_dot_lim_curr;
            dPcdotlim_dPcdot(i)   = dPcdotlim_dPcdot_curr;
            dPcdotlim_dPc(i)      = dPcdotlim_dPc_curr;
            
            %keyboard
        else
            delta_Pc_dot_lim(i) = delta_Pc_dot(i);
            dPcdotlim_dPcdot(i) = 1;
            dPcdotlim_dPc(i)    = 0;
            
            
        end
    elseif delta_Pc_dot(i)>0
        if delta_Pc(i) > Reg_up(i)
            delta_Pc_dot_lim(i) = 0;
            dPcdotlim_dPcdot(i) = 0;
            dPcdotlim_dPc(i)    = 0;
            
            
        elseif delta_Pc(i) <= Reg_up(i) && delta_Pc(i) > Reg_up(i)*0.99
            delta_Pc_dot_lim_curr = delta_Pc_dot(i)*ppval(Pcdotlim_Ru_spline(i),delta_Pc(i));
            dPcdotlim_dPc_curr    = delta_Pc_dot(i)*ppval(dPcdotlim_dPc_upsp(i),delta_Pc(i));
            dPcdotlim_dPcdot_curr = ppval(dPcdotlim_dPcdot_upsp(i),delta_Pc(i));
            
            delta_Pc_dot_lim(i)   = delta_Pc_dot_lim_curr;
            dPcdotlim_dPcdot(i)   = dPcdotlim_dPcdot_curr;
            dPcdotlim_dPc(i)      = dPcdotlim_dPc_curr;
            
            % keyboard
        else
            delta_Pc_dot_lim(i) = delta_Pc_dot(i);
            dPcdotlim_dPcdot(i) = 1;
            dPcdotlim_dPc(i)    = 0;
            
        end
    else
        delta_Pc_dot_lim(i) = delta_Pc_dot(i);
        dPcdotlim_dPcdot(i) = 1;
        dPcdotlim_dPc(i)    = 0;
        
    end
end


end

