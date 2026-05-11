% SYNTAX
%    [grid_s] = circConv2(grid, conv_x_pixels, conv_y_pixels)
%
% DESCRIPTION
%    Perform a convolution of x by y pixel, replicating the map to limit border effects
%
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Giulio Tagliaferro
%  Contributors:      Giulio Tagliaferro, Andrea Gatti ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function [grid_s] = circConv2(grid, conv_x_pixels, conv_y_pixels)

if (nargin == 2)
    if numel(conv_x_pixels) > 2
        kernel = conv_x_pixels;
        conv_x_pixels = size(kernel,2);
        conv_y_pixels = size(kernel,1);
    elseif numel(conv_x_pixels) == 2
        conv_y_pixels = conv_x_pixels(2);
        conv_x_pixels = conv_x_pixels(1);
        kernel = ones(conv_y_pixels, conv_x_pixels) / (conv_y_pixels * conv_x_pixels);
    else
        conv_y_pixels = conv_x_pixels(1);
        conv_x_pixels = conv_x_pixels(1);
        kernel = ones(conv_x_pixels, conv_x_pixels) / (conv_x_pixels * conv_x_pixels);
    end
else
    %    if Conv_x_pixels == Conv_y_pixels;
    %        kernel = fspecial('disk', Conv_y_pixels);
    %    else
    %        kernel = fspecial('average', [conv_y_pixels, conv_x_pixels]); % with image processing toolbox
    kernel = ones(conv_y_pixels, conv_x_pixels) / (conv_y_pixels * conv_x_pixels);
    %    end
end
grid_pad = [flipud(grid(1 : conv_y_pixels, :)); grid ; flipud(grid(end-conv_y_pixels : end, :))];
grid_pad = [fliplr(grid_pad(:, 1 : conv_x_pixels)) grid_pad fliplr(grid_pad(:, end - conv_x_pixels : end))];

GridPadS = conv2(grid_pad, kernel, 'same'); % old method (no image toolbox)
%GridPadS = imfilter(GridPad,kernel,'replicate'); % new method

grid_s = GridPadS(conv_y_pixels+1:end-conv_y_pixels-1,conv_x_pixels+1:end-conv_x_pixels-1);