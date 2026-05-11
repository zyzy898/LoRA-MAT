% wrapper of fallback in case no mex
% Optimized and stabilized iterative LOWESS smoothing with Huber weights and Tikhonov regularization
%
% INPUT
%   time: time points corresponding to data (in MATLAB time format)
%   data: input data as a column vector
%         if the second column is present count it as variance
%   win_size: window size for local regression in seconds
%   iterations: number of iterations for weighting scheme
%   lambda: regularization parameter
%
% SYNTAX:
%   smoothed = iterativeLowess(time, data, win_size, iterations, lambda)


%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function smoothed = iterativeLowess(time, data, win_size, iterations, lambda)

    if (nargin <= 2) || isempty(win_size)
        % Estimate win_size
        total_time_seconds = (max(time) - min(time)) * 24 * 60 * 60; % Convert days to seconds
        win_size = 0.1 * total_time_seconds;
    end

    if (nargin <= 3) || isempty(iterations)
        % Estimate iterations
        iterations = 3; % Typically, 3 to 5 iterations are sufficient
    end

    if (nargin <= 4) || isempty(lambda)
        % Estimate lambda
        % A heuristic: fraction of the trace of the data's covariance matrix
        X = [ones(length(time), 1), time];
        s = svd(X);
        lambda = 1e-3 * max(s);
    end

    % Initialize weights and data
    if size(data,2) == 2
        weights = 1 ./ sqrt(data(:, 2) + eps); % Avoid division by zero
        data = data(:, 1);
    else
        weights = []; % No weights needed for single-column data
    end

    n = size(data,1);
    smoothed = data;  % Initial smoothed values
    frac_days = win_size / 86400;  % Convert frac from seconds to days

    for iter = 1:iterations
        left = 1;
        right = 1;
        for i = 1:n
            % Update the window indices using a moving window approach
            while left < n && (time(i) - time(left)) > frac_days
                left = left + 1;
            end
            while right < n && (time(right) - time(i)) <= frac_days
                right = right + 1;
            end

            % Ensure at least 3 data points in the window for stability
            while right - left + 1 < 3 && (left > 1 || right < n)
                if left > 1
                    left = left - 1;
                elseif right < n
                    right = right + 1;
                end
            end

            x = time(left:right);
            y = data(left:right);
            w = ones(length(y), 1); % Use equal weights for single-column data
            % Calculate residuals and Huber weights
            residuals = y - smoothed(left:right);
            c = 1.345 * std(residuals);  % scale parameter
            w(abs(residuals) > c) = c ./ abs(residuals(abs(residuals) > c));
            if ~isempty(weights)
                local_weights = weights(left:right);
                w = local_weights .* w; % Combined weights
            end

            % Weighted linear regression with Tikhonov regularization
            X = [ones(length(x), 1), x];
            W = diag(w);
            beta = (X' * W * X + lambda * eye(2)) \ (X' * W * y);  % Added regularization term
            smoothed(i) = [1, time(i)] * beta;
        end
    end
end