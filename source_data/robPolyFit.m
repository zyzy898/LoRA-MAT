% Robust polynomial fitting using Huber weights.
%
% [y_out, params] = robPolyFit(x, y, deg, x_out) fits a polynomial to the
% input data (x,y) using a robust method based on iteratively re-weighted
% least squares with Huber weights. The output y_out is the polynomial
% value computed at the points x_out. If x_out is not provided, it defaults
% to x. The fitted polynomial coefficients are returned in 'params', where
% the coefficient of the highest degree term is the last element.
%
% Inputs:
% - x: Vector of independent data points.
% - y: Vector of dependent data points.
% - deg: Degree of polynomial to fit.
% - x_out: (optional) Vector of points at which to compute the polynomial value.
%
% Outputs:
% - y_out: Vector of polynomial values computed at the points in x_out.
% - params: Vector of polynomial coefficients.
%
% Example:
% [y_fit, p] = robPolyFit([1 2 3 4], [1.1 3.9 9.2 16.1], 2);
%
% Notes:
% 1. The Huber threshold 'k' is currently set to a typical value of 1.345.
%    Adjust as necessary for specific applications.
% 2. The function uses a default maximum of 50 iterations and a convergence
%    criterion of 1e-6. Adjust these values in the function if different
%    behavior is desired.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function [y_out, params] = robPolyFit(x, y, deg, x_out)
    if nargin < 4
        x_out = x;
    end

    % Huber threshold
    k = 1.345; % typical value; adjust as necessary

    % Maximum number of iterations and convergence criterion
    maxIter = 50;
    tol = 1e-6;

    % Initial weights
    w = ones(size(y));

    % Build the design matrix A for the input x
    A = zeros(length(x), deg+1);
    for j = 0:deg
        A(:,j+1) = x.^j;
    end

    % Iteratively re-weighted least squares
    for iter = 1:maxIter
        % Fit polynomial using weights
        W = diag(sqrt(w));
        params = (W * A) \ (W * y);

        % Compute residuals
        r = y - A * params;

        % Update weights using Huber function
        w_new = 1 ./ (1 + (abs(r)/k).^2);

        % Check for convergence
        if norm(w - w_new, inf) < tol
            break;
        end

        w = w_new;
    end

    % Compute output values
    A_out = zeros(length(x_out), deg+1);
    for j = 0:deg
        A_out(:,j+1) = x_out.^j;
    end
    y_out = A_out * params;
end