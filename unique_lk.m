function [ delta_Pc_lim_check_unique ] = unique_lk( delta_Pc_lim_check )
% Choose the last time of the given time step of which to take the info.
id=1;
delta_Pc_lim_check_unique = zeros(1,3);
for i=3:length(delta_Pc_lim_check)
    if delta_Pc_lim_check(i,1)~=delta_Pc_lim_check(i-1,1)
        delta_Pc_lim_check_unique(id,:)=delta_Pc_lim_check(i-2,:);
        id=id+1;
    end
end


end

