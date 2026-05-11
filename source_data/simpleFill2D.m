function [data] = simpleFill2D(data, flags, fun)
% SYNTAX:
%    [data_filled] = simpleFill1D(data, flags)
%
% DESCRIPTION:
%    fill flagged data with a simple interpolation using MATLAB
%    interp1 'pchip', 'extrap'
%
% NOTE: data can be a matrix, the operation is executed column by column
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if nargin < 3
        % Correlation function
        fun = @(dist) exp(-(dist).^2);
end

    x_g = 1 : size(data,2);
    y_g = 1 : size(data,1);
    
    [x_mesh, y_mesh] = meshgrid(x_g, y_g);
    
    x_p = x_mesh(:);
    x_o = x_mesh(~flags);
    
    y_p = y_mesh(:);
    y_o = y_mesh(~flags);
    
    data_o = data(~flags);
    
    for x = 1 : size(data,2)
        id_p = (x_p == x);
        if sum(id_p) > 0
            tmp_x_p = x_p(id_p);
            tmp_y_p = y_p(id_p);
            d = sqrt((repmat(tmp_x_p, 1, size(x_o,1)) - repmat(x_o', size(tmp_x_p, 1), 1)).^2 + ...
                (repmat(tmp_y_p, 1, size(y_o,1)) - repmat(y_o', size(tmp_y_p, 1), 1)).^2);
            %d = d / sqrt(sum(size(data).^2));
            data(id_p) = ((fun(d) * data_o) ./ sum(fun(d),2));
        end            
    end
end