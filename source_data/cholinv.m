function invA = cholinv(A)

% SYNTAX:
%   invA = cholinv(A);
%
% INPUT:
%   A = positive definite matrix to be inverted
%
% OUTPUT:
%   invA = inverse of matrix A
%
% DESCRIPTION:
%   Inverse of a positive definite matrix by using Cholesky decomposition.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Nardo
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

% compute cholesky decomposition
n = size(A,1);
U    = chol(A);
invU = U\speye(n);
%L    = inv(L);
invA = invU * invU';