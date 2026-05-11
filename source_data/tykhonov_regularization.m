function [x_hat, bias, lbd] = tykhonov_regularization(x, y0, b, A, Q)

% SYNTAX:
%   [x_hat, bias, lbd] = tykhonov_regularization(x, y0, b, A, Q);
%
% INPUT:
%   x  = least-squares estimates
%   y0 = observation vector
%   b  = known term vector
%   A  = design matrix
%   Q  = cofactor matrix
%
% OUTPUT:
%   x_hat = estimates using the regularization parameter lambda
%   bias  = bias from regularization
%   lbd   = regularization parameter
%
% DESCRIPTION:
%   Tykhonov-Phillips regularization applied to least-squares.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     Hendy F. Suhandri, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

alp   = 0;    %initial value of alpha
Dalp  = 1;    %initial value of delta_alpha
tol   = 1e-3; %tolerance value
cnt1  = 0;

%normal matrix
N = (A'*(Q^-1)*A);

%number of parameters
n = size(A,2);

%identity matrix
I = eye(n);

while (abs(Dalp) > tol && cnt1 < 1e4);
    alp_o = alp; %initial value
    alp   = (trace(N*(N + alp*I)^-3))/(x'*(N + alp*I)^-2*N*(N + alp*I)^-1*x); %compute alpha
    Dalp  = alp - alp_o;
    cnt1  = cnt1 + 1;
end

lbd  = alp; %take lambda value from alpha
Dlbd = 1;
tol  = 1e-5;
cnt2 = 0;
N2   = N + lbd*I;

while (abs(Dlbd) > tol && cnt2 < 1e4);
    lbd_o = lbd;
    lbd   = (trace(N*N2^-3))/(x'*N2^-2*N*N2^-1*x); %compute lambda
    Dlbd  = lbd - lbd_o;
    cnt2  = cnt2 + 1;
    N2    = N + lbd*I;
end
x_hat = ((N + lbd*I)^-1)*A'*Q^-1*(y0-b);
bias  = -lbd * (N + lbd*I)^-1 * x;