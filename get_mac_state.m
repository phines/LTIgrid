function mac = get_mac_state(ps,mode)
% usage: mac = get_mac_state(ps,mode)
%  ps - ps structure typical
%  mode is one of the following:
%   'classical', Ea behind Xd
%   'salient', Salient pole machine
%   'linear', a very simple linear model

% NOTE that this function assumes that there is one mac entry per gen, in
% the same sequence.

% grab some data
C  = psconstants;
Pg = ps.gen(:,C.ge.Pg)/ps.baseMVA;
Qg = ps.gen(:,C.ge.Qg)/ps.baseMVA;
G  = ps.bus_i(ps.gen(:,1));
Va = ps.bus(G,C.bu.Vmag);
%theta_g = ps.bus(G,C.bu.Vang)*pi/180;
Xd = ps.mac(:,C.ma.Xd);
Xq = ps.mac(:,C.ma.Xq);
D  = ps.mac(:,C.ma.D);
mac = ps.mac;
ng = size(mac,1);
omega_0 = 2*pi*ps.frequency;

switch mode
    case 'classical'
        % find Pm in per unit
        mac(:,C.ma.Pm) = Pg + D; % at nominal frequency
        % find delta
        delta_m_theta = atan2( Pg , ( Qg + Va.^2 ./ Xd ) );
        delta = delta_m_theta; % changed from delta_m_theta + theta_g;
        mac(:,C.ma.delta) = delta;
        % find Ea
        Ea_mag = Pg .* Xd ./ ( Va .* sin(delta) );
        mac(:,C.ma.Ea) = Ea_mag;
        % delta_dot = 0
        mac(:,C.ma.omega) = omega_0;
    case 'salient'
        if any(Xq==0)
            error('we need Xq values to do salient pole model');
        end
        nropt = numerics_options;
        nropt.nr.verbose=0;
        for i=1:ng
            eq = @(Ea_delta) salient_eqs(Ea_delta,Va(i),Xd(i),Xq(i),Pg(i),Qg(i));
            Ea_delta0 = [Va(i)*1.1;10*pi/180];
            Ea_delta = nrsolve(eq,Ea_delta0,nropt);
            mac(i,C.ma.Ea) = Ea_delta(1);
            mac(i,C.ma.delta) = Ea_delta(2);
            mac(i,C.ma.omega) = omega_0;
            mac(i,C.ma.Pm0) = Pg(i) + D(i); % at nominal frequency
        end
    case 'linear'
        % find the machine mechanical power
        mac(:,C.ma.Pm) = Pg; % at nominal frequency
        % machine speed
        mac(:,C.ma.omega) = omega_0;
        % machine rotor angle
        mac(:,C.ma.delta_m) = Pg.*Xd;
    otherwise
        error('not a valid mode for get_mac_state');
end


