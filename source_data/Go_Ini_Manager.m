% =========================================================================
%   thisECT Go_Ini_Manager => for goGPS
%   father: Ini_Manager
% =========================================================================
%
% DESCRIPTION:
%   thisect to create / read / modify an ini file
%
% EXTENDS: Ini_Reader
%
% INI EXAMPLE:
%   [Section 1]
%       array = [1 2 3]
%       string = "I'm a string"
%       stringCellArray = ["I" "am" "a string cell" "array"]
%   ; I'm a comment
%   # I'm also a comment
%   [Section 2]
%       number = 10
%   [Section n]     # comment
%       double = 10.4
%
% REQUIRES:
%   log:     Logger Class
%   cprintf:    http://www.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-the-command-window
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

classdef Go_Ini_Manager < Ini_Manager

    properties (GetAccess = 'private', SetAccess = 'private')
        cutoff = 10;
        csThr = 3;
        snrThr = 0;
    end

    methods
        function this = Go_Ini_Manager(file_name, raw_data)
            args = {};
            if nargin >= 1
                args{1} = file_name;
            end
            if nargin >= 2
                args{2} = raw_data;
            end
            this = this@Ini_Manager(args{:});
        end
    end

    methods (Access = 'public')


        function nR = getNumRec(this)
            % Get the number of receiver in the INI
            nR = this.getData('Receivers','nRec');
        end

        function rate = getCaptureRate(this)
            % Get the sampling rate (Hz) to be used in monitor mode
            rate = this.getData('Monitor', 'rate');
            if isempty(rate)
                rate = 1;
            end
        end

        function setCaptureRate(this, rate)
            % Set the sampling rate (Hz) to be used in monitor mode
            rate = str2double(rate(1:2));
            this.addData('Monitor', 'rate', rate);
        end

        function [dataPath fileName nR] = getRecFiles(this)
            % Get the dataPath containing the files, file names and number of available receivers
            nR = getNumRec(this);

            dataPath = this.getData('Receivers','data_path');
            if (isempty(dataPath))
                dataPath = '';
            end

            fileName = this.getData('Receivers','file_name');
            if (isempty(fileName))
                fileName = '';
            else
                % If missing, get the number of receiver from the file name list
                if isempty(nR)
                    nR = length(fileName);
                end
            end

            % If I have only one receiver fileName is not a cell => convert it
            if nR == 1
                tmp = fileName;
                fileName = cell(1);
                fileName{1} = tmp;
            end
        end

        function [geometry ev_point] = getGeometry(this)
            % Get the receiver coordinates in instrumental RF
            geometry = zeros(3,this.getNumRec());
            for r = 1:this.getNumRec()
               geometry(:,r) = this.getData('Antennas RF',['XYZ_ant' num2str(r)]);
            end
            ev_point = this.getData('Antennas RF','XYZ_ev_point');
        end

        function cutoff = getCutoff(this)
            % Get the minimum angle of acceptance for a satellite
            cutoff = this.getData('Generic','cutoff');
            if (isempty(cutoff))
                cutoff = this.cutoff;
            end
        end

        function csThr = getCsThr(this)
            % Get the threshold to identify a cycle slip
            csThr = this.getData('Generic','csThr');
            if (isempty(csThr))
                csThr = this.csThr;
            end
        end

        function snrThr = getSnrThr(this)
            % Get the minimum SNR threshold acceptable
            snrThr = this.getData('Generic','snrThr');
            if (isempty(snrThr))
                snrThr = this.snrThr;
            end
        end

        function timeStep = getTimeStep(this)
            % Get time increment (e.g. v = obs(t+timeStep)-obs(t)
            timeStep = this.getData('Variometric','timeStep');
            if (isempty(timeStep))
                timeStep = 1;
            end
        end

    end

end