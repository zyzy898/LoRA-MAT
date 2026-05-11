% Fits a sigmoid function to provided data.
%
% [line_fit, params] = sigmoidFit(x, y, x_out) fits a sigmoid function to
% the input data (x,y). The output line_fit is the sigmoid function value
% computed at the points x_out. If x_out is not provided, it defaults to a
% linspace from the minimum to the maximum of x with 1000 points. The
% function returns the parameters of the fitted sigmoid in 'params' in the
% order: [a, L, k, x0].
%
% Inputs:
% - x: Vector of independent data points.
% - y: Vector of dependent data points.
% - x_out: (optional) Vector of points at which to compute the sigmoid value.
%
% Outputs:
% - line_fit: Vector of sigmoid function values computed at the points in x_out.
% - params: Vector of fitted parameters for the sigmoid [a, L, k, x0].
%
% Nested Functions:
% - sigmoidModel: Defines the sigmoid model.
% - residuals: Computes the residuals between the data and the model.
%
% Example:
% [y_fit, p] = sigmoidFit([1 2 3 4], [0.2 0.5 0.8 0.95]);
%
% Notes:
% 1. The initial guess for the parameters is based on the provided data,
%    namely the minimum and maximum of y, 0.5 for 'k', and the median of
%    the logarithm of x for 'x0'.
% 2. The optimization settings currently use a function tolerance of 1e-6
%    and a maximum of 1000 iterations. Adjust these values in the function
%    if different behavior is desired.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function [line_fit, params] = sigmoidFit(x, y, x_out)
    % If x_out is not provided, set default values
    if nargin < 3
        x_out = linspace(min(x), max(x), 1000);
    end

    % Initial guess for parameters [a, L, k, x0]
    params_initial = [min(y), max(y), 0.5, median(log(x))];

    options = optimset('TolFun', 1e-6, 'MaxIter', 1000);
    params = fminsearch(@(p) sum(residuals(p, x, y).^2), params_initial, options);

    % Compute the fitted line
    a = params(1);
    L = params(2);
    k = params(3);
    x0 = params(4);
    line_fit = sigmoidModel(x_out, a, L, k, x0);
end

function y = sigmoidModel(x, a, L, k, x0)
    % Define the sigmoid model
    y = a + (L - a) ./ (1 + exp(-k * (log(x) - x0)));
end

function res = residuals(params, x, y)
    % Compute the residuals between the data and the model
    a = params(1);
    L = params(2);
    k = params(3);
    x0 = params(4);

    y_fit = sigmoidModel(x, a, L, k, x0);
    res = y - y_fit;
end