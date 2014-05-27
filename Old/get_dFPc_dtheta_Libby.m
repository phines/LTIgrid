function df_dy = get_dFPc_dtheta_Libby(ps,df_dy)

% constants
C     = psconstants_will;
nmacs = size(ps.mac,1);
n     = size(ps.bus,1);
ix    = get_indices_will(n,nmacs);

% extract data from ps
K_ace     = ps.areas(:,C.ar.K);
br_status = ps.branch(:,C.br.status)~=0;
br_x      = ps.branch(br_status,C.br.X);
nA        = length(ps.tie_lines_F);

% for each area, put the appropriate Pc_dot with the machines
gen_bus_i = ps.bus_i(ps.gen(:,1));
gen_areas = ps.bus(gen_bus_i,C.bu.area);
keyboard
for i = 1:nA
    % get buses in area 1
    bus_tie_locs = ps.bus_tie_locs_F{i};
    if isempty(bus_tie_locs)
        bus_tie_locs = ps.bus_tie_locs_T{i};
    end
    % calcuate dFPc_dtheta
    for k = 1:length(bus_tie_locs)
        cols = bus_tie_locs(k);
        for h = 1:nA
            gen_subset = (gen_areas==h);
            % first get the flow on the time lines out
            tie_lines_from = ps.tie_lines_F{h}(:);
            if isempty(tie_lines_from)
                dFPc_out = 0;
            else
                dFPc_out = -K_ace(h)./ br_x(tie_lines_from(k));
            end
            
            % then get the flow on the time lines in
            tie_lines_to = ps.tie_lines_T{h}(:);
            if isempty(tie_lines_to)
                dFPc_in = 0;
            else
                dFPc_in = K_ace(h)./ br_x(tie_lines_to(k));
            end
            % dFPc_dtheta
            dFPc_dtheta = dFPc_out + dFPc_in;
            if mod(i,2) > 0
                df_dy = df_dy + sparse(ix.f.Pc_dot(gen_subset),cols,-dFPc_dtheta,ix.nx,ix.ny);
            else
                df_dy = df_dy + sparse(ix.f.Pc_dot(gen_subset),cols,dFPc_dtheta,ix.nx,ix.ny);
            end
        end
    end
end
keyboard
