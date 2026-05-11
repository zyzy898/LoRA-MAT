function rgb_img = exportAsImage(file_name, data, cmap, min_max, x0, y0, x1, y1)
% SYNTAX:
%   rgb_img = exportAsImage(file_name, data, cmap, min_max, x0, y0, x1, y1)
%   rgb_img = exportAsImage(file_name, data, cmap, min_max, x1, y1)
%
% INPUT:
%   file_name
%   data      [n x m] image
%   min_max   limits of the image (empty to avoid saturation)
%   x0, y0    meshgrid of original coordinate ( or size of the original image)
%   x1, y1    meshgrid of final exported coordinate ( or size of the final exported image)
%
% OUTPUT:
%   rgb_img = [n x m x 3] RGB image
%
% DESCRIPTION:
%   Convert an grayscale image to a rgb image

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    narginchk(3,8);

    if (nargin == 3) || isempty(min_max)
        min_max = [min(data(:)) max(data(:))];
    end

    if (nargin == 6)
        x1 = x0;
        y1 = y0;
        x0 = size(data,1);
        y0 = size(data,2);
    end
    if (nargin == 6) || (nargin == 8)
        if (numel(x0) == 1)
            x0 = 1 : x0;
            y0 = 1 : y0;
            x1 = 1 : x1;
            y1 = 1 : y1;
            [x0, y0] = meshgrid(x0, y0);
            [x1, y1] = meshgrid(x1, y1);
        end
        tic; data = interp2(x0, y0, data, x1, y1, 'spline'); toc;
    end
    clear x0 x1 y0 y1;
    rgb_img = img2rgb(data, cmap, min_max);
    imwrite(rgb_img, file_name);
end