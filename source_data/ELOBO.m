function [x_k, s02_k, v_k, Cxx_k, N_inv] = ELOBO(A, Q, y0, b, N_inv, v, x, s02, subset)
% SYNTAX:
%   [x_k, s2_k, v_k, Cxx_k, N_inv] = ELOBO(A, Q, y, b, N_inv, v, x, s02, subset)
%
% INPUT:
%   A     : design matrix of the full problem
%   Q     : cofactor matrix of the full problem
%   y     : observation vector of the full problem
%   Ninv  : inverse of normal matrix of the full problem
%   x     : estimated parameters of the full problem
%   s02   : a posteriori sigma of the full problem
%   subset: index of observations of y that compose the testing block
%
% OUTPUT:
%   x_k  : estimated parameters without the testing block
%   s2_k : a posteriori sigma without the testing block
%   v_k  : estimated residuals without the testing block
%   Cxx_k: parameters covariance without the testing block
%
% DESCRIPTION:
%   perform ELOBO on blocks of correlated observations
%   identify one (block) outlier
%   reject it
%   re-estimate unknowns
%   according to the theory in "L. Biagi and S. Caldera. An efficient leave one block out approach to identify outliers.Journal of Applied Geodesy, Volume 7, Issue 1, pages 11..19, 2013"
%
%   this version is optimized to manage blocks!

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Stefano Caldera
%  Contributors:     Stefano Caldera, Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if isempty(N_inv)
        N_inv = cholinv(A'/Q*A);
    end
    [n_obs, n_col] = size(A);
    Ak = A(subset,:);
    Qk = Q(subset,subset);
    vk = v(subset,:);
    Bk = N_inv * Ak';
    Ck = Ak * Bk;
    Kk = Qk - Ck;
    if n_obs-n_col-length(subset) < 1
        log = Core.getLogger();
        log.addWarning(sprintf('Cluster cannot be checked. Redudancy = %d', n_obs - n_col - length(subset)));
    else
        BKk_inv = Bk / Kk;
        x_k = x - BKk_inv * vk;
        s02_k = ((n_obs - n_col) * s02 - vk' / Kk * vk) / (n_obs - n_col - length(subset));
        N_inv_fin = N_inv + BKk_inv * Bk';
        Cxx_k = s02_k * N_inv_fin;
        id_ok = setdiff(1 : size(A, 1), subset);
        y_k = A(id_ok, :) * x_k + b(id_ok);
        v_k = y0(id_ok) - y_k;
    end
end