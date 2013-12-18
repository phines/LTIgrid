clear all; close all;
% load some data
ps = case9_ps; % get the real one?
ps = updateps(ps);
ps = dcpf(ps); % dc power flow
ps.mac = get_mac_state(ps,'linear');
n = size(ps.bus,1);
ng = size(ps.gen,1);
ix = get_indices(n,ng);

for(i=1:n),
    for(j=i+1:n),
        [x0,y0] = get_xy(ps);
        %%Simulate a line outage
         C = psconstants;
        br_st = ps.branch(:,C.br.status)~=0;
        X = ps.branch(br_st,C.br.X);
        n = size(ps.bus,1);
        F = full(ps.bus_i(ps.branch(br_st,1)));
        T = full(ps.bus_i(ps.branch(br_st,2)));

        b_FT = (-1./X);
        B = sparse(F,T,-b_FT,n,n) + ...
            sparse(T,F,-b_FT,n,n) + ...
            sparse(T,T,+b_FT,n,n) + ...
            sparse(F,F,+b_FT,n,n);

        B=full(B);

        y1=y0;

        Lnow=pinv(B);

        Bpir=B;

        Bpir(i,j)=10;
        Bpir(j,i)=10;

        Bpir(i,i)=Bpir(i,i)-10;
        Bpir(j,j)=Bpir(j,j)-10;

        Lpir=pinv(B);


        y0=(eye(n,n)-Lpir*(Bpir-B))*y0; %These equations are correct it just 
        y0=y0-ones(n,1)*y0(1);          %might take awhile to explain why. 
        
        theta=y0;
        
        
        ix = get_indices(n,ng);
        mac_bus_i = ps.bus_i(ps.mac(:,1));
        delta = ps.mac(:,C.ma.delta_m) + theta(mac_bus_i);
        x0(ix.x.delta)= delta;
        
        Y0=y1;


        xy_0 = [x0;y0];
        t = 0;

        %% test the steady state system
        fn_fg = @(t,xy) differential_algebraic_eqs(t,xy,ps);
        Jac   = get_jacobian(t,xy_0,ps);
        mass_matrix = sparse(1:ix.nf,1:ix.nx,1,ix.nf+ix.ng,ix.nx+ix.ny);
        options = odeset(   'Mass',mass_matrix, ...
                            'MassSingular','yes', ...
                            'Jacobian', Jac, ...
                            'Stats','on', ... 
                            'MStateDependence','none',...
                            'NormControl','off');



        tic
        [t,xy_out] = ode23t(fn_fg,[0 50],xy_0,options);
        toc

        %% plot something
        x_out = xy_out(:,(1:ix.nx));
        y_out = xy_out(:,(1:ix.ny)+ix.nx);

        delta = x_out(:,ix.x.delta);
        figure(1); clf;
        plot(t,delta');
        xlabel('Time (seconds)');
        ylabel('Machine angles (radians)');
    end
end


