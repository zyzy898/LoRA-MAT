% wrapper of fallback in case no mex
%  compile it with make robAdj
% it is not the same code, instead of huber it uses the simple median
%
% ROBADJ applies a robust adjustment to a time series, ignoring NaNs.
%
% INPUT:
%   sensor: An n x m array representing the time series.
%   weights: An n x m array representing the weights (optional).
%
% OUTPUT:
%   out: An n x 1 array representing the adjusted time series.
%
% SYNTAX: [out] = robAdj(sensor, weights)

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti, Giulio Tagliaferro
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function [out] = robAdj(sensor, weights)
    % Fast simple approach: out = median(sensor, 2, 'omitnan');

    if nargin < 2
        weights = [];
    end

    [n_ep, ~] = size(sensor);
    thrs = 0.02;

    out = zeros(n_ep, 1);

    % For all the epochs
    for k = 1:n_ep
        % Get the values of the row
        data_tmp = sensor(k, :);
        if ~isempty(weights)
            weight_tmp = weights(k, :);
        else
            weight_tmp = [];
        end

        % Ignore NaN values
        id_ok = isfinite(data_tmp);
        data_tmp = data_tmp(id_ok);
        if ~isempty(weight_tmp)
            weight_tmp = weight_tmp(id_ok);
        end

        if ~isempty(data_tmp) % If we have values
            if isempty(weights)
                w = ones(size(data_tmp));
            else
                w = weight_tmp / sum(weight_tmp);
            end
            w0 = w;
            j = 0;
            dt = 1e9;
            dt_prev = -1e9;
            while (j < 20 && abs(dt - dt_prev) > 0.005) % Limit the reweight to 20 or less than 0.005 improvement
                dt_prev = dt;
                tmp = data_tmp .* w;
                dt = sum(tmp) / sum(w); % Weighted mean

                ares_n = abs(data_tmp - dt) / thrs; % Absolute residuals
                w = ones(size(data_tmp));
                idx_rw = find(ares_n > 1); % Residual to be reweighted
                if ~isempty(idx_rw)
                    w(idx_rw) = 1 ./ ares_n(idx_rw).^2; % Compute the weight
                end
                w = w .* w0;
                j = j + 1;
            end
            out(k) = dt; % Put in the results
        end
    end
end