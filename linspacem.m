function y = linspacem(x1,x2,n)

%LINSPACEM Linearly Spaced Array.
% LINSPACEM(X1,X2,N) where X1 and X2 are scalars generates a
% row vector of N equally spaced points between X1 and X2.
%
% If X1 and X2 are row vectors of the same size, LINSPACEN(X1,X2,N)
% creates a matrix having N rows where the i-th column of the result
% contains N equally spaced points between X1(i) and X2(i).
%
% If X1 and X2 are column vectors of the same size, LINSPACEN(X1,X2,N)
% creates a matrix having N columns where the i-th row of the result
% contains N equally spaced points between X1(i) and X2(i).
% For N<2 or X1=X2 LINSPACEM returns X2.
%
% If N is not provided, N=100 is used.
%
% See also: LINSPACE, LOGSPACE, LOGSPACEM

% Mukhtar Ullah
% mukhtar.ullah@informatic.uni-rostock.de
% September 5, 2004

if nargin==2, n = 100; end

if ~isscalar(n), error('3rd argument must be scalar'), end

[x1,x2,sz] = sclrexpnd(x1,x2);

if n < 2 || isequal(x1,x2) , y = x2; return, end

n = floor(n);
x1 = x1(:); 
x2 = x2(:);
d = repmat((x2-x1)/(n-1), 1, n-2);
y = [cumsum([x1 d], 2)  x2];
y = squeeze(reshape(y, [sz n]));

if sz(1) == 1, y = y.'; end