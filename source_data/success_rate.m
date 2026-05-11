function [up_bound, lo_bound] = success_rate(D, L, bias)

% SYNTAX:
%   [up_bound, lo_bound] = success_rate(D, L, bias);
%
% INPUT:
%   Qahat = vcm of ambiguity
%   D = diagonal matrix of decorrelated Qahat
%   L = lower triangular matrix of decorrelated Qahat
%   bias = detected bias, if available
%
% OUTPUT:
%   up_bound = upper bound of success rate based on ADOP
%   lo_bound = lower bound of success rate based on bootstrapping method
%
% DESCRIPTION:
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Hendy F. Suhandri
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

%%define some input
%------------------
n    = length(D);
beta = L^-1 * bias;

%adop = det(Qahat)^(1/m);
s_ad = (D).^1/(2*n);
adop = prod(s_ad);

%%compute upper bound
%--------------------
u =1/(2*adop);
q = normcdf(u,0,1);
up_bound = (2*q - 1)^n;

%%compute lower bound
%--------------------

for i = 1:n
    u1 = (1 - 2*beta(i))/(2*sqrt(D(i)));
    u2 = (1 + 2*beta(i))/(2*sqrt(D(i)));
    q1 = normcdf(u1,0,1);
    q2 = normcdf(u2,0,1);
    lo_bound = prod(q1 + q2 - 1);
    %lo_bound = prod(lo_bound);
end