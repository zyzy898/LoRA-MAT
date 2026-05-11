% DESCRIPTION:
% Run this script to get the objects used by goGPS 
% when you finished your execution.
% Parsing these objects you can retrive all the results.
%
% OUTPUT:
%   core      the core processor object containing all the goGPS structures
%   rec       the last session array of Receivers
%   rec_list  when enabled in SESSION settings it stores all the Receivers
%             for all the processed sessions
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

core = Core.getCurrentCore();
rec = core.rec;
try
    coo = rec.getCoo;
catch
    coo = Coordinates();
end

log = Core.getLogger();
log.addMarkedMessage('Now you should be able to see 3 new variables:');
log.addMessage(log.indent(' - core      the core processor object containing all the goGPS structures'));
log.addMessage(log.indent(' - rec       the array of Receivers (core.rec)'));
log.addMessage(log.indent(' - coo       the array of coordinates (rec.getCoo)'));
log.newLine();