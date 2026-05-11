%   SINGLETON CLASS Encyclopedia
% =========================================================================
%
% DESCRIPTION
%   This class allows the declaration of the definitions
%
% EXAMPLE
%   log = Encyclopedia.getInstance();
%
%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Giulio Tagliaferro
%  Contributors:      Giulio Tagliaferro
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

classdef Encyclopedia < handle
    properties
        observation_group = {};
    end
    methods (Static)
        function this = getInstance(std_out)
            % Concrete implementation.  See Singleton superclass.
            persistent unique_instance_encyclopedia__
            if isempty(unique_instance_encyclopedia__)
                this = Logger();
                unique_instance_encyclopedia__ = this;
            else
                this = unique_instance_encyclopedia__;
            end
        end
    end
    
    methods 
        function addObsGroup(this, obs_group)
            this.observation_group{end+1} = obs_group;
        end
        
        function id = getObsGroupId(this, obs_group)
                id = Core_Utils.findAinB(obs_group, this.observation_group);
                if id == 0
                    this.addObsGroup(obs_group);
                    id = length(this.observation_group);
                end
        end
    end
end