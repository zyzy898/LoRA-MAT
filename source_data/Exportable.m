%   CLASS Exportable
% =========================================================================
%
% DESCRIPTION
%   Abstract class with basic properties and methods that to import / export objects
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Gatti
%  Contributors:     Andrea Gatti, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

classdef Exportable < handle

    methods (Access = public)
    end

    methods

    end

    methods (Abstract)
        %copy = getCopy(this);
    end

    % =========================================================================
    %  INTERFACE REQUIREMENTS
    % =========================================================================
    methods
        function out = toStruct(this, flag_ignore_err)
            % Export to struct all the fields of the object
            %
            % DISCLAMER
            %   Partial support, only works on non objects and public properties
            %
            % SYNTAX
            %   out = this.toStruct(flag_ignore_err)
            if nargin < 3
                flag_ignore_err = true;
            end
            log = Core.getLogger();
            cm = log.getColorMode();
            log.setColorMode(false);
            warning off
            if (numel(this) == 0)
                out = [];
            end
            for i = 1 : numel(this)
                tmp = struct(this(i));
                if isfield(tmp, 'PreviousInstance__')
                    tmp = rmfield(tmp,'PreviousInstance__');
                end
                prp = fieldnames(tmp);
                out(i) = tmp;

                for p = 1 : numel(prp)
                    if isobject(out(i).(prp{p}))
                        % Manage app singletons
                        try
                            out(i).(prp{p}) = this(i).(prp{p}).toStruct;
                        catch ex
                            if not(flag_ignore_err)
                                log.addWarning(ex.message)
                            end
                        end
                    end
                end
            end
            warning on
            log.setColorMode(cm);
        end

        function importFromStruct(this, struct_in, flag_ignore_err)
            % Import from struct
            %
            % DISCLAMER
            %   Partial support, only works on non objects and public properties
            %
            % SYNTAX:
            %   this.importFromStruct(fields_list, flag_ignore_err)
            if nargin < 3 || isempty(flag_ignore_err)
                flag_ignore_err = true;
            end

            log = Core.getLogger();

            prp = fieldnames(struct_in);
            for p = 1 : numel(prp)
                try
                    if isobject(this.(prp{p}))
                        try
                            this.(prp{p}) = this.(prp{p}).fromStruct(struct_in.(prp{p}));
                        catch ex
                            if not(flag_ignore_err)
                                log.addWarning(ex.message)
                            end
                        end
                    else
                        try
                            this.(prp{p}) = struct_in.(prp{p});
                        catch ex
                            % typically here I have an error for read only properties
                            if not(flag_ignore_err)
                                log.addWarning(ex.message)
                            end
                        end
                    end
                catch ex
                    % typically here I have an error for non public properties
                    if not(flag_ignore_err)
                        log.addWarning(ex.message)
                    end
                end
            end
        end
    end

end