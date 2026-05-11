function setTimeTicks(num, format, ax)
% SYNTAX:
%   setTimeTicks(num,format);
%   setTimeTicks(ax, num,format);
%
% EXAMPLE:
%   setTimeTicks(4,'dd/mm/yyyy HH:MM');
%
% INPUT:
%   num      = number of tick to be shown
%   format   = time format => see datetick for more informations
%
% DESCRIPTION:
%   display a number of tick = num
%   showing the UTC date in the format required
%   the X axis should contain time values in UTC format
%
% REMARKS:
%  setTimeTicks uses the 'tag' and 'userdata' properties of the figure.
%  zoom and pan callbacks are used
%  (whenever another callback is present, it is appended - works with qplot)
%
% SEE ALSO:
%   resetTimeTicks qplot

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

    if (nargin > 0) && (nargin ~= 3) && isa(num, 'handle')
        if nargin == 2
            num = format;
            format = 'auto';        
        else
            h = num;
            num = 8;
        end
    elseif (nargin < 3)
        h = gca;
    elseif nargin == 3
        h = num;
        num = format;
        format = ax;
    end

    if nargin < 1 || isempty(num)
        num = 9;
    end

    if nargin < 2 || isempty(format)
        format = 'auto';
    end

    
    ttData.num = num;
    ttData.format = format;

    hZoom = zoom(h);
    hPan = pan(ancestor(h,'figure'));

    %     ttData.hZoom = get(hZoom,'ActionPostCallback');
    %     ttData.hPan = get(hPan,'ActionPostCallback');

    set(h, 'userdata', ttData);

    set(hZoom, 'ActionPostCallback', @zoomCallback);
    set(hPan , 'ActionPostCallback', @panCallback);

    resetTimeTicks(h, num, format);
end

function zoomCallback(obj, ev)
    resetTimeTicks(ev.Axes, ev.Axes.UserData.num, ev.Axes.UserData.format);
%     if ~isempty(obj.UserData.hZoom)
%         obj.UserData.hZoom(obj,ev);
%     end
end

function panCallback(obj, ev)
    resetTimeTicks(ev.Axes, ev.Axes.UserData.num, ev.Axes.UserData.format);
%     if ~isempty(obj.UserData.hPan)
%         obj.UserData.hPan(obj,ev);
%     end
end