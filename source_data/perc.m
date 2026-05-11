function perc_val = perc(data, p)
% SYNTAX:
%   perc_val = perc(data, thr)
%
% INPUT:
%   data    array of values
%   p       percentile requested (0 1]
%
% OUTPUT:
%   perc_val
%
% DESCRIPTION:
%   returns percentile of the values in data

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    data(isnan(data)) = [];
    if size(data,1) == 1 || size(data,2) == 1
        data = sort(data(:));
    else
        for c = 1:size(data,2)
            data(:,c) = sort(data(:,c));
        end
    end
    if numel(data) > 0
        for c = 1:size(data,2)
            for v = 1:numel(p)
                perc_val(c,v) = data(min(max(round(size(data,1) * p(v)),1), size(data,1)),c);
            end
        end
    else
        perc_val = 0;
    end
end