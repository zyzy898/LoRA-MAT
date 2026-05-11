% tsFilter - Detect and filter outliers in a time series data
%
% SYNTAX:
%   [smoothed_data, id_ko, smoothed_spline, data_filtered] = tsFilter(time, data, big_win, thr_big, small_win, thr_small)
%
% INPUT:
%   time        : Time vector (can be in GPS_Time format or MATLAB time format)
%   data        : Time series data as a column vector second column can be variances
%   big_win     : Window size for detecting large outliers (in days)
%   thr_big     : Threshold multiplier for detecting large outliers
%   small_win   : (Optional) Window size for detecting small outliers (in days)
%   thr_small   : (Optional) Threshold multiplier for detecting small outliers
%
% OUTPUTS:
%   smoothed_data   : Data after removing detected outliers
%   id_ko           : Flags
%   smoothed_spline : Smoothed spline representation of the data
%   data_filtered   : Data with detected outliers set to NaN
%
% DESCRIPTION:
%   This function detects and filters outliers in a time series data using
%   a two-stage robust filtering approach. In the first stage, large outliers
%   are detected and removed using a large window size. In the optional second
%   stage, smaller outliers are detected using a smaller window size. The function
%   also computes a smoothed spline representation of the data.
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function [smoothed_data, id_ko, smoothed_spline, data_filtered] = tsFilter(time, data, big_win, thr_big, small_win, thr_small, varargin)

    % Convert time if in GPS_Time format
    if isa(time,'GPS_Time')
        time = time.getMatlabTime;
    end

    % Initialize
    data_filtered = data(:,1);

    % Large outliers detection and filtering
    smoothed_data = robFilt(time, [data_filtered data(:,2)], big_win);
    residuals = data_filtered - smoothed_data;
    id_ko = (abs(residuals) / robStd(residuals)) > thr_big;
    %data_filtered(id_ko) = nan;

    flag_2step = nargin > 5 && ~isempty(small_win) && ~isempty(thr_small);
    flag_plot = (nargin == 7  && strcmp(varargin{1}, '-plot')) || (nargin == 5  && strcmp(small_win, '-plot'));

    % Small outliers detection (if parameters provided)
    if flag_2step
        residuals(id_ko) = (2*residuals(id_ko)).^2; % weight more residuals above the threshold
        smoothed_data = robFilt(time, [data_filtered residuals.^2], small_win);
        residuals = data(:,1) - smoothed_data;
        id_ko = (abs(residuals) / robStd(data_filtered - smoothed_data)) > thr_small;
    end

    % Compute smoothed_spline with smoothed data based weights (if output requested)
    if nargout > 2 || flag_plot
        residuals(id_ko) = (2*residuals(id_ko)).^2; % weight more residuals above the threshold
        if flag_2step
            smoothed_spline = splinerMat(time, [smoothed_data residuals.^2], small_win / 2, 1e-5);
        else
            smoothed_spline = splinerMat(time, [smoothed_data residuals.^2], big_win / 2, 1e-5);
        end
    end

    % Prepare data_filtered for output (if output requested)
    if nargout > 3 || flag_plot
        data_filtered = data(:,1);
        data_filtered(id_ko) = nan;
    end

    % Plotting
    if flag_plot
        fh = figure;
        plot(time, data(:,1), '.', 'color', [0.5 0.5 0.5]);
        hold on;
        plotSep(time, data_filtered, '.-', 'color', Core_UI.getColor(1));
        plotSep(time, smoothed_data,'.-');
        plot(time, smoothed_spline,'.-');
        setAllLinesWidth(2);
        ylim(minMax(data_filtered(:)) + 0.1*[-1 1] * diff(minMax(data_filtered(:))));
        legend('Original Data', 'FilteredData', 'robFilt', 'robSpline');
        Core_UI.addLineMenu(fh);
    end
end