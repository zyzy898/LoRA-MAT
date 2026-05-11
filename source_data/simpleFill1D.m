function [data] = simpleFill1D(data, flags, method, time)
% Fill in flags position
%
% SYNTAX:
%    [data_filled] = simpleFill1D(data, flags, <method>)
%
% DESCRIPTION:
%    fill flagged data with a simple interpolation using MATLAB
%    interp1 'linear', 'pchip' (default), 'extrap', 'last'
%
%   'last' is not a standard interpolation method, it uses the last
%   valid epoch of an arc to fill all the consecutive nan values
%
% NOTE: data can be a matrix, the operation is executed column by column
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

%     if nargin == 2
%         half_win = 6;
%     end
%
%     lim = getFlagsLimits(flags);
%     for j = 1 : size(lim, 1)
%         dt_lhs = data(max(1, lim(j, 1) - half_win) : lim(j, 1) - 1);
%         dt_rhs = data(lim(j, 2) + 1 : min(numel(data), lim(j, 2) + half_win));
%         data(lim(j,1):lim(j,2)) = interp1([ lim(j, 1) - numel(dt_lhs) : lim(j, 1) - 1,  lim(j, 2) + 1 : lim(j, 2) + numel(dt_rhs)], [dt_lhs; dt_rhs], lim(j,1) : lim(j,2), 'pchip','extrap');
%     end
    narginchk(2,4);
    if nargin == 2 || isempty(method)
        method = 'pchip';
    end

    if strcmp(method, 'last')
        for s = 1 : size(data, 2)
            lim = getFlagsLimits(flags(:,s));
            % if the data starts with nan do nothing
            if ~isempty(lim) && lim(1) == 1
                lim(1, :) = [];
            end
            for l = 1 : size(lim, 1)
                data(lim(l,1) : lim(l,2), s) = data(lim(l,1) - 1, s);
            end
        end
    else
        if nargin == 4 && ~isempty(time)
            t = time;
        else
            t = 1 : size(data, 1);
        end
        for r = 1 : size(data, 2)
            if any(~isnan(data(:, r))) && any(~isnan(flags(:, r))) && any(~flags(:, r))
                jmp = find(flags(:, r));
                flags(:, r) = flags(:, r) | isnan(data(:, r));
                if sum(~flags(:, r)) > 1
                    data(jmp, r) = interp1(t(~flags(:, r)), data(~flags(:, r), r), t(jmp), method, 'extrap');
                end
            end
        end
    end
end