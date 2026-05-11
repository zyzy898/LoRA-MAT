function [emp_cov, dist] = empCov2(x_obs, y_obs, data_obs, n_classes)
% SYNTAX:
%   [emp_cov, dist] = empCov2(x_obs, y_obs, data_obs, n_classes)
%
% DESCRIPTION:
%   return the array of the empirical covariance funtion
%
% EXAMPLE:
%   [emp_cov, dist] = empCov2(e_obs(id_td), n_obs(id_td), td_obs);
%   figure; plot(dist, emp_cov, 'b'); hold on;

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if nargin < 4
        n_classes = 50;
    end

    [x_mesh, y_mesh] = meshgrid(x_obs, y_obs);
    d_obs = sqrt(abs(x_mesh - x_mesh').^2 + abs(y_mesh - y_mesh').^2);
    classes = ceil(d_obs / max(d_obs(:)) * (n_classes-1))+1;

    emp_cov = zeros(max(classes(:)), size(data_obs,2));
    for i = 1 : size(data_obs,2)
        corr = (data_obs(:,i)-mean(data_obs(:,i), 'omitnan')) * (data_obs(:,i)-mean(data_obs(:,i), 'omitnan'))';
        for c = 1 : max(classes)
            emp_cov(c, i) = mean(corr(serialize(triu(classes)==c)), 'omitnan');
        end
    end
    emp_cov = mean(emp_cov, 2, 'omitnan');
    dist = (0 : (n_classes - 1))' * max(d_obs(:))/n_classes;
end