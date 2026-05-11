% Fits data to a polynomial of a specified degree plus a logarithmic term.
%
% [fitFunc, coeffs, x_out] = polyLogFit(x, y, deg, x_out) fits the input 
% data (x,y) to a polynomial of degree 'deg' plus an additional logarithmic 
% term. The output fitFunc is the fitted function value computed at the points 
% x_out. If x_out is not provided, it defaults to a logarithmic spacing 
% from the minimum to the maximum of x with 100 points. The function returns 
% the coefficients of the fitted polynomial plus the logarithmic term in 
% 'coeffs'.
%
% Inputs:
% - x: Vector of independent data points.
% - y: Vector of dependent data points.
% - deg: Degree of polynomial to fit.
% - x_out: (optional) Vector of points at which to compute the fitted values.
%
% Outputs:
% - fitFunc: Vector of fitted function values computed at the points in x_out.
% - coeffs: Vector of fitted coefficients for the polynomial and the logarithmic term.
% - x_out: Vector of points at which the fitted values were computed.
%
% Example:
% [y_fit, p, x_vals] = polyLogFit([1 2 3 4], [1.1 2.9 6.2 10.1], 2);
%
% Notes:
% 1. The function fits data to a polynomial of the form: 
%    a_n*x^n + a_{n-1}*x^{n-1} + ... + a_1*x + a_0 + b*log(x), where 'n' 
%    is the degree specified and 'b' is the coefficient of the logarithmic term.
% 2. The coefficients are returned in descending order of power of 'x', 
%    followed by the logarithmic term coefficient.
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function [fitFunc, coeffs, x_out] = polyLogFit(x, y, deg, x_out)
    % Function to fit data to a polynomial of degree 'deg' plus a logarithmic term
    
    if nargin < 4
        x_out = logspace(log10(min(x)), log10(max(x)), 100);
    end

    % Create a matrix with columns [x^n, x^{n-1}, ..., x, 1, log(x)]
    X = zeros(length(x), deg+2);
    for i = 1:deg
        X(:,i) = x.^(deg+1-i);
    end
    X(:,end-1) = ones(size(x));
    X(:,end) = log(x);

    % Solve for the coefficients using a least-squares approach
    coeffs = X \ y;

    % Generate the fit for the provided x_out values
    X_out = zeros(length(x_out), deg+2);
    for i = 1:deg
        X_out(:,i) = x_out.^(deg+1-i);
    end
    X_out(:,end-1) = ones(size(x_out));
    X_out(:,end) = log(x_out);
    fitFunc = X_out * coeffs;
end