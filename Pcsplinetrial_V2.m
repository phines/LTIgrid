function [ delta_Pc_dot_lim,dPcdotlim_dPcdot ] = Pcsplinetrial_V2( delta_Pc,delta_Pc_dot,Reg_up,Reg_down,perc  )
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
              dPcdotlim_dPcdot(i)=1;
        elseif delta_Pc(i) >= Reg_down(i) && delta_Pc(i) < Reg_down(i)*(1-perc/100)
            x=0:.1:10;
            y=sigmf(x,[2,5]);
            y=y(end:-1:1);
            y=y-1;
            x=x/max(x)*(Reg_down(i)*(1-perc/100)-Reg_down(i));
            x=x+Reg_down(i);
            y=y*abs(delta_Pc_dot(i));
            delta_Pc_dot_lim_up_sigm = spline(x,y);
            delta_Pc_dot_lim(i) = ppval(delta_Pc_dot_lim_up_sigm,delta_Pc(i));
            dPcdotlim_dPcdot(i)=1; %FIX
            %keyboard
        else
            delta_Pc_dot_lim(i)=delta_Pc_dot(i);
            dPcdotlim_dPcdot(i)=1;
        end
    elseif delta_Pc_dot(i)>0
        if delta_Pc(i) > Reg_up(i)
            delta_Pc_dot_lim(i)=0;
            %dPcdotlim_dPcdot(i)=0;
               dPcdotlim_dPcdot(i)=1;
        elseif delta_Pc(i) <= Reg_up(i) && delta_Pc(i) > Reg_up(i)*(1-perc/100)
            x=0:.1:10;
            y=sigmf(x,[2,5]);
            y=y(end:-1:1);
            x=x/max(x)*(Reg_up(i)-Reg_up(i)*(1-perc/100));
            x=x+Reg_up(i)*(1-perc/100);
            y=y*delta_Pc_dot(i);
            delta_Pc_dot_lim_up_sigm = spline(x,y);
            delta_Pc_dot_lim(i) = ppval(delta_Pc_dot_lim_up_sigm,delta_Pc(i));
            dPcdotlim_dPcdot(i)=1; %FIX
           % keyboard
        else
            delta_Pc_dot_lim(i)=delta_Pc_dot(i);
            dPcdotlim_dPcdot(i)=1;
        end
    else
        delta_Pc_dot_lim(i)=delta_Pc_dot(i);
        dPcdotlim_dPcdot(i)=1;
    end
end


end

