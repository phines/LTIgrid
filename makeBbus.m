function B = makeBbus(ps)
% a simple bus susceptance matrix

C = psconstants;

br_status = ps.branch(:,C.br.status)==1;
F = ps.bus_i(ps.branch(br_status,1));
T = ps.bus_i(ps.branch(br_status,2));
X = ps.branch(br_status,C.br.X);
n = size(ps.bus,1);

inv_X = (1./X);
B = sparse(F,T,-inv_X,n,n) + ...
    sparse(T,F,-inv_X,n,n) + ...
    sparse(T,T,+inv_X,n,n) + ...
    sparse(F,F,+inv_X,n,n);
