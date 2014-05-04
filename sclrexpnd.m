function [varargout] = sclrexpnd(varargin)
% SCLREXPND expands scalars to the size of non-scalars.
%    [X1,X2,...,Xn] = SCLREXPND(X1,X2,...,Xn) expands the scalar 
%    arguments, if any, to the (common) size of the non-scalar arguments,
%    if any.
%
%    [X1,X2,...,Xn,SIZ] = SCLREXPND(X1,X2,...,Xn) also returns the 
%    resulting common size in SIZ.  
%
% Example:
% >> c1 = 1; c2 = rand(2,3); c3 = 5; c4 = rand(2,3);
% >> [c1,c2,c3,c4,sz] = sclrexpnd(c1,c2,c3,c4)
%
% c1 =
%      1     1     1
%      1     1     1
% 
% c2 =
%     0.7036    0.1146    0.3654
%     0.4850    0.6649    0.1400
% 
% c3 =
%      5     5     5
%      5     5     5
% 
% c4 =
%     0.5668    0.6739    0.9616
%     0.8230    0.9994    0.0589
% 
% sz =
%      2     3

% Mukhtar Ullah
% November 2, 2004
% mukhtar.ullah@informatik.uni-rostock.de

C = varargin;
issC = cellfun('prodofsize',C) == 1;
if issC
    sz = [1 1];
else
    nsC = C(~issC);   
    if ~isscalar(nsC)
        for i = 1:numel(nsC), nsC{i}(:) = 0;  end
        if ~isequal(nsC{:})
            error('non-scalar arguments must have the same size')
        end
    end    
    s = find(issC);
    sz = size(nsC{1});      
    for i = 1:numel(s)
        C{s(i)} = C{s(i)}(ones(sz));
    end        
end
varargout = [C {sz}];