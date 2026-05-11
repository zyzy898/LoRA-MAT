function [lid_ko, clean_data] = getOutliers(data, sigma, win_size, n_sigma_win, n_sigma_jmp, range)
% getOutliers identifies and removes outliers in a relatively constant time series
%
% INPUT
%   data          - data array
%   sigma         - standard deviation level
%   win_size      - size of the moving window for outlier detection
%   n_sigma_win   - sigma threshold to consider the moving window as affected by outliers
%   n_sigma_jmp   - sigma threshold to detect an outlier
%   range         - minimum and maximum acceptable values for the data
%
% OUTPUT
%   lid_ko        - indices of detected outliers
%   clean_data    - data array with outliers removed
%
% SYNTAX
%   [id_ko, clean_data] = getOutliers(data, sigma, win_size, n_sigma_win, n_sigma_jmp, range)
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    % Compute thresholds - empirical but it works (outliers should be less than 75% percent)
    if nargin < 2 || isempty(sigma)
        thr_perc = 0.75;
        tmp = diff(data);
        tmp(abs(tmp) > 3 * perc(noNaN(abs(tmp)), thr_perc)) = nan;
        sigma = std(tmp, 'omitnan');
        sigma(isnan(sigma)) = median(sigma, 'omitnan');
        clear tmp;
    end
    if nargin < 3 || isempty(win_size)
        win_size = 7;                % window size for outlier detection
    end
    if nargin < 4 || isempty(n_sigma_win)
        n_sigma_win = 2;
    end
    if nargin < 5 || isempty(n_sigma_jmp)
        n_sigma_jmp = 4;
    end
    mu_win = 3 * win_size;

    % Keep jumps bigger than 1 meters
    big_jumps = diff(movmedian(data(:,1), 31, 'omitnan'));
    big_jumps(abs(big_jumps) < 1e3) = 0;
    big_jumps = [0; cumsum(big_jumps)];
    clean_data = data(:,1) - big_jumps;
    big_jumps = big_jumps + median(clean_data, 'omitnan');
    clean_data = clean_data - median(clean_data, 'omitnan');
    %clean_data = data(:,1);

    % Initialization

    % Determine maximum acceptable value range
    if nargin < 6 || isempty(range)
        mov_range = perc(noNaN(diff(clean_data)), [0.2 0.5 0.8]);
        mov_range = mov_range([1 3]) + [-40 40]' .* diff(mov_range);

        tmp = nan2zero(movmedian(clean_data, round(win_size), 'omitnan'));
        lid_ko = clean_data < (tmp + mov_range(1)) | (clean_data > (tmp + mov_range(2)));

        range = perc(clean_data, [0.2 0.5 0.8]);
        range = range([1 3]) + [-6 6]' .* diff(range);
    else
        lid_ko = true(size(clean_data));
    end
    lid_ko = (clean_data < -1e4 | clean_data > 1e+4) | (lid_ko & (clean_data < range(1) | clean_data > range(2))); % if it is around the normal range 80% of data it's ok
    clean_data(lid_ko) = tmp(lid_ko);
    clean_data = clean_data + big_jumps;


    % Detection of outliers from formal sigma (usually underestimated)
    lid_ko = lid_ko | isnan(clean_data(:,1));
    if size(data,2) == 2
        % there is also std
        lid_ko(data(:,2) > 6 * sigma) = true;
        clean_data(lid_ko) = nan;
    end

    % Outlier parameters
    jmp_ok = n_sigma_jmp * sigma;     % A jump smaller than this threshold is ok
    sigma_ok = n_sigma_win * sigma;   % A sigma under this level in a moving window of min_win size is acceptable

    % compute running std
    tmp_win_size = min(numel(clean_data), win_size);
    std_ko = movstd(clean_data, tmp_win_size, 'Endpoints', 'discard');
    std_ko(isnan(std_ko)) = 1e10;
    std_ko = std_ko > sigma_ok/1.5;
    std_ko = [std_ko; repmat(std_ko(end), tmp_win_size - 1, 1)];
    % Start outlier detection
    for k = 1:2
        for i = 1:length(clean_data)
            if ~lid_ko(i)
                % Check for outliers ------------------------------------------
                if std_ko(i)
                    win = clean_data(i : min(length(clean_data), i -1 + win_size)); % window in the future
                    if sum(not(isnan((win)))) > 4
                        win = win - (1:numel(win))' * median(diff(clean_data(i : min(length(clean_data), i -1 + 2*win_size))), 'omitnan'); % reduce for trend
                    end
                    while (std(win, 'omitnan') > sigma_ok) || any(abs(diff(win)) > sigma_ok) % if future obs are unstable shrink the window
                        win(end) = [];
                    end

                    % If the window have been shortened there is probably on outlier in the window
                    if sum(not(isnan(win))) < 5
                        % check the current epoch with a window in the past
                        win = clean_data(max(1, i - win_size + 1) : i);
                        if sum(not(isnan((win)))) > 4
                            win = win - (1:numel(win))' * median(diff(clean_data(max(1, i - 2*win_size + 1) : i)), 'omitnan'); % reduce for trend
                        end
                        if any(isnan(win))
                            mu = median(clean_data(max(1, i - mu_win + 1):(i-1)), 'omitnan');
                            if not(any(mu))
                                mu = median(clean_data(max(1, i - 5*mu_win + 1):(i-1)), 'omitnan');
                            end
                            win(isnan(win)) = mu; % set nan values t the actual running mean
                        end
                        % if the sigma is above thr or if the last epoch is jumping too much
                        if length(win) == 1 || std(win, 'omitnan') > sigma_ok || ((length(win) > 1) && abs(diff(win(end-1:end))) > jmp_ok)
                            % the current epoch is an outlier
                            %fprintf('Outlier detected %d\n', i);
                            clean_data(i) = nan;
                            lid_ko(i) = true;
                        end
                    end
                end
                % -------------------------------------------------------------
            end
        end
    end
    clean_data(lid_ko) = nan;
    %clean_data = clean_data + big_jumps; % restore jumps
    %fprintf('%d outliers found\n', sum(id_ko))
    %figure; plot(clean_data, 'o');
end