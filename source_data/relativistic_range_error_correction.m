function [corr, distSR_corr] = relativistic_range_error_correction(XR, XS)

% SYNTAX:
%   [corr, distSR_corr] = relativistic_range_error_correction(XR, XS);
%
% INPUT:
%   XR = receiver position  (X,Y,Z)
%   XS = satellite position (X,Y,Z)
%
% OUTPUT:
%   corr = relativistic range error correction term
%   distSR_corr = corrected satellite-receiver distance
%
% DESCRIPTION:
%   Computation of the relativistic range error correction term (Shapiro
%   signal propagation delay).

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

distR = sqrt(sum(XR.^2 ,1));
distS = sqrt(sum(XS.^2 ,2));

XR_mat = XR(:,ones(size(XS,1),1))';
distSR = sqrt(sum((XS-XR_mat).^2 ,2));

% switch char(Eph(31))
%     case 'G'
%         %GM = goGNSS.GM_GPS;
        GM = 3.986005e14;
%     case 'R'
%         %GM = goGNSS.GM_GLO;
%         GM = 3.9860044e14;
%     case 'E'
%         %GM = goGNSS.GM_GAL;
%         GM = 3.986004418e14;
%     case 'C'
%         %GM = goGNSS.GM_BDS;
%         GM = 3.986004418e14;
%     case 'J'
%         %GM = goGNSS.GM_QZS;
%         GM = 3.986005e14;
%     otherwise
%         fprintf('Something went wrong in ecc_anomaly.m\nUnrecongized Satellite system!\n');
%         %GM = goGNSS.GM_GPS;
%         GM = 3.986005e14;
% end

corr = 2*GM/(Core_Utils.V_LIGHT^2)*log((distR + distS + distSR)./(distR + distS - distSR));

distSR_corr = distSR + corr;