% Applies a pick position filter within a moving window across a data series.
%
% The function slides a window of specified size across the data series and,
% at each position, sorts the values within the window. It then picks a value
% based on the specified pick position within the sorted window. This method
% is useful for filtering data with a specific selection criterion that depends
% on the rank of data points within a moving window.
%
% INPUT:
%   data: An n x 1 array representing the data series.
%   filterSize: An integer representing the size of the moving window. The size
%               should be odd to ensure symmetry around the center of the window.
%   pickPos: An integer representing the zero-based position within the sorted
%            window to pick as the output for each window position. For example,
%            a pickPos of 0 picks the smallest value within the window, and a
%            pickPos equal to (filterSize-1)/2 picks the median.
%
% OUTPUT:
%   filteredData: An n x 1 array representing the filtered data series. The output
%                 at each point is determined by the pickPos within the sorted
%                 values of the window centered at that point.
%
% SYNTAX:
%   filteredData = pickfilt(data, filterSize, pickPos)
%
% EXAMPLE:
%   data = [1, 3, 5, 7, 9, 11];
%   filterSize = 3;
%   pickPos = 1; % Picks the middle (median) value in a sorted window of 3 elements
%   filteredData = pickfilt(data, filterSize, pickPos);
%   % This will apply a median filter of size 3 across 'data'

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function filteredData = pickfilt(data, filter_size, pick_pos)
    % Ensure filter size is odd
    filter_size = filter_size + mod(filter_size+1, 2);
    half_size = (filter_size-1) / 2;
    lengthData = length(data);

    % Initialize filtered data array
    filteredData = zeros(size(data));

    % Preallocate window with zeros
    win = zeros(1, filter_size);

    % Handle edge cases for the beginning of the data
    for i = 1:half_size
        win = sort(data(max(1, i-half_size):min(lengthData, i+half_size)));
        filteredData(i) = win(min(end, pick_pos+1));
    end

    % Main loop for the data (excluding edges)
    for i = half_size+1:lengthData-half_size
        win = sort(data(i-half_size:i+half_size));
        filteredData(i) = win(pick_pos+1);
    end

    % Handle edge cases for the end of the data
    for i = lengthData-half_size+1:lengthData
        win = sort(data(max(1, i-half_size):min(lengthData, i+half_size)));
        filteredData(i) = win(min(end, pick_pos+1));
    end
end