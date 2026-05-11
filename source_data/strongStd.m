function std_out = strongStd(data, robustness_perc)
% Returns the std removing outliers (spikes)
%
% INPUT:
%   data                column array of values
%   robustness_perc     maximum percentage of date with no outliers
%
% SYNTAX:
%   std_out = strongStd(data, robustness_perc)

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if nargin == 1
        robustness_perc = 0.8;
    end
    data_tmp = data - movmedian(data, 3, 'omitnan');
    thr1 = perc(abs(data_tmp), ceil(numel(data_tmp) * robustness_perc) / numel(data_tmp));
    id_ok = abs(data_tmp) < (6 * thr1);
    std_out = std(data(id_ok));
    id_ok = abs(data) < (6 * std_out);
    std_out = std(data(id_ok)) ;
end