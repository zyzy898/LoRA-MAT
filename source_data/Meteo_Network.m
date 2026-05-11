%   CLASS Meteo_Network
% =========================================================================
%
% DESCRIPTION
%   Class to store and manage a network of meteo station
%
% EXAMPLE
%   settings = Meteo_Network();
%
% FOR A LIST OF CONSTANTs and METHODS use doc Meteo_Data
%
% REFERENCE

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti, Giulio Tagliaferro ...
%  Contributors:      Andrea Gatti, Giulio Tagliaferro ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

classdef Meteo_Network < handle
    properties
        mds % list of meteo data
        log % handfle of logger
    end
    %% METHOD CREATOR
    % ==================================================================================================================================================
    methods (Static)
        % Concrete implementation.  See Singleton superclass.
        function this = Meteo_Network()
            this.log = Core.getLogger();
            this.mds = Meteo_Data();
            this.mds(1) = [];
        end
    end

    %% METHODS UI
    % ==================================================================================================================================================
    methods (Static, Access = public)
        function ok_go = openGUI()
            ok_go = gui_goGPS;
        end
    end

    methods (Access = public)
        function initSession(this, date_start, date_stop)
            % Load all the metereological data
            %
            % SYNTAX
            % this.initSession(data_start, data_stop)

            this.mds = [];
            % load all meteo file present in current settings
            state = Core.getCurrentSettings();
            fnames = state.getMetFileName(date_start, date_stop);
            this.initFromFileList(fnames)
        end

        function initFromFileList(this, file_name_list)
            % Load metereological data directly from file list
            %
            % INPUT
            %   file_name_list: two level cells, first level station second level days
            %
            % SYNTAX
            %   this.initFromFileList(file_name_list)

            n_files = numel(file_name_list);
            this.mds = Meteo_Data;
            this.mds(1) = [];
            for  f = 1 : n_files
                if iscell(file_name_list{f})
                    n_sss = numel(file_name_list{f});
                    for  s = 1 : n_sss
                        if ~isempty(File_Name_Processor.getFileName(file_name_list{f}{s}))
                            if ~exist(file_name_list{f}{s}, 'file')
                                this.log.addWarning(sprintf('Skipping %s - file not found', file_name_list{f}{s}));
                            else
                                [~, ~, ext] = fileparts(file_name_list{f}{s});
                                if strcmp(ext, '.mat')
                                    tmp = load(file_name_list{f}{s}, 'mds');
                                    if ~isfield(tmp, 'mds') || isempty(tmp.mds)
                                        mds = Meteo_Data;
                                        mds.setValid(false);
                                    else
                                        mds = tmp.mds;
                                    end
                                else
                                    mds = Meteo_Data(file_name_list{f}{s});
                                end
                                for m = 1:numel(mds)
                                    if mds(m).isValid()
                                        [~, ids] = this.mds.get(mds(m).getMarkerName);
                                        if isempty(ids)
                                            this.mds = [this.mds; mds(m)];
                                        else
                                            this.mds(ids).inject(mds(m));
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        function md = getVMS(this, name, xyz, time)
            % Get Virtual Meteo Station
            %
            % INPUT
            %   name    name of the new Meteo_Data virtual station
            %   xyz     coordinates of the new meteo station
            %   time    time of interpolation
            %
            %
            % OUTPUT
            %   md      virtual Meteo_Data station generated at xyz coordinates
            %
            % SYNTAX
            %   md = this.getVMS(name, xyz, time)
            %
            % EXAMPLE
            %   [x, y, z, amsl] = station(1).getLocation();
            %   md1 = this.getVMS('test', [x y z], station(1).getObsTime)
            md = Meteo_Data.getVMS( name, xyz, time, this.mds);
        end
    end

end