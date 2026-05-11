% Special wrapper to regular plot
% Works on regularly sampled data
% When there is a gap of data, it insert a nan value
% to avoid linear interpolation of the data
%
% INPUT
%   t           column array of epochs
%   data        columns of data (could be a matrix)
%   varagin     add other useful parameters of the plot
%
% SYNTAX
%   Core_Utils.plotSep(t, data, varagin);
%
% SEE ALSO
%   plot

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------


function lh = plotSep(t, data, varargin)
    if not(isempty(data))
        if isa(t, 'handle')
            ax = t;
            t = data;
            data = varargin{1};
            varargin = varargin{2:end};
        else
            ax = gca;
        end
        try
            if numel(t) ~= numel(data) && numel(t) ~= size(data, 1)
                % this means that there is only one data parameter and no time
                varargin = [{data} varargin];
                data = t;
                if size(data, 1) == 1
                    % I want the data to be columnwise
                    data = data';
                end
                t = (1 : size(data, 1))';
            else
                if size(data, 1) == 1
                    % I want the data to be columnwise
                    data = data';
                end
            end
        catch ex
            % probably data is undefined
            data = t;
            if size(data, 1) == 1
                % I want the data to be columnwise
                data = data';
            end
            t = (1 : size(data, 1))';
        end
        for c = 1 : size(data, 2)
            if numel(data) == numel(t)
                [t_col, data_col] = insertNan4Plots(t(:,c), data(:,c));
            else
                [t_col, data_col] = insertNan4Plots(t, data(:,c));
            end
            if isempty(varargin)
                lh = plot(ax, t_col, data_col);
            else
                lh = plot(ax, t_col, data_col, varargin{:});
            end
            hold on;
        end
    end
end

function [t, data_set] = insertNan4Plots(t, data_set)
    % Insert a Nan in a regularly sampled dataset to make
    % plots interrupt continuous lines
    %
    % INPUT
    %   t      epoch of the data [matrix of column arrays]
    %   data   epoch of the data [matrix of column arrays]
    %
    % SYNTAX
    %   [t, data] = Core_Utils.insertNan4Plots(t, data)

    t = t(:);
    if size(t, 1) ~= size(data_set, 1)
        % data should be a column array
        data_set = data_set';
    end
    n_set = size(data_set, 2);
    dt = diff(t);
    rate = median(dt);
    id_in = find(dt > 1.5 * rate);
    for x = numel(id_in) : -1 : 1
        t = [t(1 : id_in(x)); (t(id_in(x)) + 1.5 * rate); t((id_in(x)+1) : end)];
        data_set = [data_set(1 : id_in(x), :); nan(1, n_set); data_set((id_in(x)+1) : end, :)];
    end
end