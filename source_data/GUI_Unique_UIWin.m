%   CLASS GUI_Unique_UIWin
% =========================================================================
%
% DESCRIPTION
%   Parent class for goGPS windows
%
%
% FOR A LIST OF CONSTANTs and METHODS use doc GUI_Unique_UIWin


%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

classdef GUI_Unique_UIWin < handle   
    properties (Constant, Abstract)
        WIN_NAME
    end
    
    %% PROPERTIES SINGLETON POINTERS
    % ==================================================================================================================================================
    
    %% PROPERTIES GUI
    % ==================================================================================================================================================
    properties (Abstract)
        win                          matlab.ui.Figure
    end    
   
    %% METHOD CREATOR
    % ==================================================================================================================================================
    methods (Static, Access = protected)
        function this = GUI_Unique_UIWin()
            % GUI_Unique_UIWin object creator
        end
    end
    %% METHODS UTILITY
    % ==================================================================================================================================================
    methods                                
        function fig_handle = getUniqueWinHandle(this)
            
            fig_handle = [];
            if ~isempty(this.win) && isvalid(this.win)
                % if the win is open and stored in this singleton object
                fig_handle = this.win;
            end
            % clean way of doing this:
            % fig_handle = findobj(get(groot, 'Children'), 'UserData', this.WIN_NAME);
            
            % fast way of doing this:
            fh_list = get(groot, 'Children');
            fh_list = setdiff(fh_list, fig_handle);
            
            % bad code writing style but fast
            for f = 1 : numel(fh_list)
                try
                    if isfield(fh_list(f).UserData, 'name') && strcmp(fh_list(f).UserData.name, this.WIN_NAME)
                        % If there are lone Edit figures close them
                        delete(fh_list(f));
                    end
                catch ex
                    Core_Utils.printEx(ex);
                end
            end
        end         
        
        function bringOnTop(this)
            % Bring the window on top of all the others
            this.win.Visible = 'on';
            figure(this.win);
            drawnow
        end
    end       
end