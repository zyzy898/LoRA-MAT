% Return the robust sigma of the series
% The robust mean error
%
% INPUT
%   data    [n x 1]
%
% SYNTAX
%   sigma] = robStd(data)

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function [sigma] = robStd(data)
    sigma = robAdj((abs(data - robAdj(data(:)')))');
end