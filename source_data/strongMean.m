function [smean sstd] = strongMean(data, thr_perc, thr_perc_global, n_sigma)
% Returns the mean per column with a certaint percentile of values in data
% The code uses only the data filtered by the requested percentile to estimate
% an std column by column
% With this estimation only the data within n_sigma range are used for the
% robust mean estimation
%
% SYNTAX:
%   smean = strongMean(data, thr_perc, thr_perc_global, n_sigma)
%
% INPUT:
%   data                matrix of values
%   thr_perc            percentile requested [0 1] per column
%   thr_perc_global     percentile requested [0 1] global
%   n_sigma             number of sigmas
%
% OUTPUT:
%   smean   strong mean per column
%   sstd    std ot the values used for the mean

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    sstd = nan;
    if nargin < 2
        thr_perc = 1;
    end

    if nargin < 4
        n_sigma = 2;
    end

    % remove the median
    sensor = data;
    smean = zeros(1, size(data, 2));
    for c = 1 : size(data, 2)
        if any(nan2zero(sensor(:, c)))
            sensor(:, c) = sensor(:, c) - median(sensor(:, c), 'omitnan');
        end
    end

    if nargin >= 3 && ~isnan(thr_perc_global) && (thr_perc_global < 1)
        thr = perc(serialize(noNaN(abs(sensor))), thr_perc_global);
        id_ko = abs(sensor) > thr;
    else
        id_ko = false(size(sensor));
    end

    for c = 1 : size(data, 2)
        if any(nan2zero(sensor(:, c)))
            if ~isempty(thr_perc) && thr_perc < 1
                id_ok = abs(sensor(:, c)) < perc(noNaN(abs(sensor(:, c))), thr_perc) & ~id_ko(:, c);
            else
                id_ok = ~id_ko(:, c);
            end

            id_ok = abs(sensor(:, c)) < n_sigma * std(sensor(id_ok, c), 'omitnan');
            if any(id_ok)
                smean(c) = mean(data(id_ok, c), 'omitnan');
                if nargout == 2
                    sstd(c) = std(data(id_ok, c), 'omitnan');
                end
            else
                try
                    smean(c) = robAdj(data(:, c), 'omitnan');
                catch
                    smean(c) = median(data(:, c), 'omitnan');
                end
                if nargout == 2
                    sstd(c) = std(data(:, c), 'omitnan');
                end
            end
        end
    end
end