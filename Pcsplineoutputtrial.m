Regup=100
Regdown=-100


[delta_Pc,delta_Pc_dot]=meshgrid(-200:200,-200:200);
xyz=zeros(length(delta_Pc)*length(delta_Pc_dot),3);
delta_Pc_dot_lim = zeros(size(delta_Pc));
nx=size(delta_Pc,1);
ny = size(delta_Pc,2);
count=1
for i=1:nx
    for j=1:ny
        delta_Pc_dot_lim_curr = Pcsplinetrial(delta_Pc(i,j),delta_Pc_dot(i,j),Regup,Regdown);
        delta_Pc_dot_lim(i,j) = delta_Pc_dot_lim_curr;
        %xyz(count,:)=[delta_Pc_curr,delta_Pc_dot_curr,delta_Pc_dot_lim_curr];
        count=count+1;
    end
end
%%
% delta_Pc_p=xyz(:,1);
% delta_Pc_dot_p=xyz(:,2);
% delta_Pc_dot_lim_p=xyz(:,3);
figure
mesh(delta_Pc,delta_Pc_dot,delta_Pc_dot_lim)
xlabel('deltaPc')
ylabel('deltaPcdot')
zlabel('deltaPcdotlim')
%scatter3(delta_Pc_p,delta_Pc_dot_p,delta_Pc_dot_lim_p,'.')