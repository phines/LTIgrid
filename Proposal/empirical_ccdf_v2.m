function [p,x] = empirical_ccdf_v2(X)

X = abs(X);
x = sort(X,1,'ascend')';
n = length(x):-1:1;
p = n/length(X);