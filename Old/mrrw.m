function x = mrrw(n,dt,mu,kappa,sigma)
% generate a mean reverting random walk signal of length N
% usage: x = mrrw(n,dt,mu,kappa,sigma)
%  n - number of points
%  dt - time step
%  mu - the mean
%  kappa - the reversion strength
%  sigma - the standard deviation of the gaussian noise

x = zeros(1,n);
x(1) = mu;

for k = 1:(n-1)
    xk = x(k);
    % the Wiener process step size
    dW = randn*dt;
    % dP = h P (M -  P) dt + s P dz
    dx = kappa*xk*(mu-xk)*dt + sigma*xk*dW;
    x(k+1) = x(k) + dx;
end
