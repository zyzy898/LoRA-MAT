function [corr] = relativistic_clock_error_correction(time, Eph, SP3, XS, VS)

% SYNTAX:
%   [corr] = relativistic_clock_error_correction(time, Eph, SP3, XS, VS);
%
% INPUT:
%   time = GPS time
%   Eph = satellite ephemeris vector
%   SP3 = struct with SP3 data
%   XS = satellite position (X,Y,Z)
%   VS = satellite velocity (X,Y,Z)
%
% OUTPUT:
%   corr = relativistic clock error correction term
%
% DESCRIPTION:
%   Computation of the relativistic clock error correction term. From the
%   Interface Specification document revision E (IS-GPS-200E), page 86.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

if (isempty(SP3)) %if not using SP3 ephemeris
    roota = Eph(4);
    ecc   = Eph(6);

    Ek = ecc_anomaly(time, Eph);
    corr = -4.442807633e-10 * ecc * roota * sin(Ek);
else
    % corr = -2 * dot(XS,VS) / (Core_Utils.V_LIGHT^2); % slower
    corr = -2 * sum(conj(XS) .* VS) / (Core_Utils.V_LIGHT ^ 2); % faster
end