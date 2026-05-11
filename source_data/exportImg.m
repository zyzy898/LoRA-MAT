function exportImg(file_name, data_map, c_map)
% Save on a file a matrix provided in "data"
%
% SYNTAX:
%   exportImg(file_name, data_map, <col_map>)

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    narginchk(2,3);
    
    if islogical(data_map)
        imwrite(data_map, file_name);
    else
        if nargin < 3
            c_map = jet(256);
        end
        
        % Normalize data
        im_alpha = isnan(data_map);
        data_map = data_map - min(data_map(:));
        data_map = max(2, ceil(data_map ./ max(data_map(:)) .* (size(c_map, 1) -1)) + 1);
        data_map(im_alpha) = 1;
        c_map = [[0, 0, 0]; c_map];
        
        im = reshape([c_map(data_map(:), 1); c_map(data_map(:), 2); c_map(data_map(:), 3)], size(data_map, 1), size(data_map, 2), 3);
        imwrite(im, file_name, 'Alpha', 1-im_alpha);
    end
end