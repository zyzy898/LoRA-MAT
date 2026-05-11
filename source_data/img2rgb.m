function rgb_img = img2rgb(img, cmap, min_max)
% SYNTAX:
%   rgb_img = img2rgb(img, minmaxm, cmap);
%
% INPUT:
%   img       image as double to be converted in rgb [n x m]
%   cmap      colormap
%   minmax    limits of the image (empty to avoid saturation)
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

    narginchk(2,3);

    if (nargin == 2)
        min_max = [min(img(:)) max(img(:))];
    end

    if diff(min_max) > 0
        id = (max(min_max(1), min(min_max(2), img)) - min_max(1)) / diff(min_max) ;
    else
        id = img * 0;
    end

    id  = floor(id * (size(cmap, 1) - 1) + 1);

    % Extract r,g,b components
    r = zeros(size(img)); r(:) = cmap(id,1);
    g = zeros(size(img)); g(:) = cmap(id,2);
    b = zeros(size(img)); b(:) = cmap(id,3);

    rgb_img = uint8(cat(3, r, g, b) * 255);
end