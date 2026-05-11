%   CLASS GPS_SS
% =========================================================================
%
% DESCRIPTION
%   container of GPS Satellite System parameters
%
% REFERENCES
%   CRS parameters, according to each GNSS system CRS definition
%   (ICD document in brackets):
%
%   *_GPS --> WGS-84   (IS-GPS200H)
%   Standard IS-GPS-200H: http://www.gps.gov/technical/icwg/IS-GPS-200H.pdf
%
%   Other useful links
%     - http://www.navipedia.net/index.php/GPS_Signal_Plan
%     - Ellipsoid: http://www.unoosa.org/pdf/icg/2012/template/WGS_84.pdf
%       note that GM and OMEGAE_DOT are redefined in the standard IS-GPS200H (GPS is not using WGS_84 values)
%     - http://www.navipedia.net/index.php/Reference_Frames_in_GNSS
%     - http://gage6.upc.es/eknot/Professional_Training/PDF/Reference_Systems.pdf

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti, Giulio Tagliaferro ...
%  Contributors:      Andrea Gatti, Giulio Tagliaferro ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

classdef GPS_SS < Satellite_System
    properties (Constant, Access = 'public')
        SYS_EXT_NAME = 'GPS';     % full name of the constellation
        SYS_NAME     = 'GPS';     % 3 characters name of the constellation, this "short name" is used as fields of the property list (struct) to identify a constellation
        SYS_C        = 'G';       % Satellite system (ss) character id

        % System frequencies as struct [MHz]
        F = struct('L1', 1575.420, ...
                   'L2', 1227.600, ...
                   'L5', 1176.450)

        % Array of supported frequencies [MHz]
        F_VEC = struct2array(GPS_SS.F) * 1e6;

        % Array of the corresponding wavelength - lambda => wavelengths
        L_VEC = 299792458 ./ GPS_SS.F_VEC;

        N_SAT = 32;       % Maximum number of satellite in the constellation
        PRN = (1 : 32)';  % Satellites id numbers as defined in the constellation

        % CODE2DATA ftp://igs.org/pub/data/format/rinex303.pdf
        CODE_RIN3_ATTRIB  = {'PXWSYLMCN F' 'PXWSYLMCDN F' 'XIQ F'}; % last letter of the observation code
        CODE_RIN3_DEFAULT_ATTRIB  = {'C' 'C' 'Q'}; % last letter of the observation code
        CODE_RIN3_2BAND  = '125'; % id for the freq as stored in F_VEC
        IONO_FREE_PREF  = ['12';'15';'25'];
        
    end

    properties (Constant, Access = 'public')
        % GPS (WGS84) Ellipsoid semi-major axis [m]
        ELL_A = 6378137;
        % GPS (WGS84) Ellipsoid flattening
        ELL_F = 1/298.257223563;
        % GPS (WGS84) Ellipsoid Eccentricity^2
        ELL_E2 = (1 - (1 - GPS_SS.ELL_F) ^ 2);
        % GPS (WGS84) Ellipsoid Eccentricity
        ELL_E = sqrt(GPS_SS.ELL_E2);
        % MEAN SQUARE RADIUS
        R_EARTH = 6373044.737;
    end

    properties (Constant, Access = 'public')
        % Structure of orbital parameters (ellipsoid, GM, OMEGA_EARTH_DOT)
        ORBITAL_P = struct('GM', 3.986005e14, ...   % Gravitational constant * (mass of Earth) [m^3/s^2]
            'OMEGAE_DOT', 7.2921151467e-5, ...      % Angular velocity of the Earth rotation [rad/s]
            'ELL',struct( ...                       % Ellipsoidal parameters GPS (WGS84)
            'A', GPS_SS.ELL_A, ...                  % Ellipsoid semi-major axis [m]
            'F', GPS_SS.ELL_F, ...                  % Ellipsoid flattening
            'E', GPS_SS.ELL_E, ...                  % Eccentricity
            'e2', GPS_SS.ELL_E2));                  % Eccentricity^2
        
        ORBITAL_INC = 55;    % Orbital inclination        
        ORBITAL_RADIUS  = 20180000 + 6378137; % Orbital radius
    end

    methods
        function this = GPS_SS(offset)
            % Creator
            % SYNTAX: GPS_SS(<offset>);
            if (nargin == 0)
                offset = 0;
            end
            this@Satellite_System(offset);
        end

        function copy = getCopy(this)
            % Get a copy of this
            copy = GPS_SS(this.getOffset());
            copy.import(this);
        end
    end
end