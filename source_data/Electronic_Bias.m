%   Electronic_Bias
% =========================================================================
%
% DESCRIPTION
%   Class to manage fixing
%
% EXAMPLE
%   EB = Electronic_Bias();
%
% SEE ALSO
% FOR A LIST OF CONSTANTs and METHODS use doc Network

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Giulio Tagliaferro
%  Contributors:      Giulio Tagliaferro, ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

classdef Electronic_Bias < handle
    properties (Constant)
        CONST = 1;
        SPLINE_LIN = 2;
        SPLINE_CUB = 6;
    end
    properties (GetAccess = public, SetAccess = public)
        o_code
        type
        data
        time_data %% WARNING must be constant rate
    end
    
    methods (Access = public)
        function this = Electronic_Bias(o_code, data, time_data, type)
            % constructor
            % SYNTAX
            % this = Electronic_Bias(data, <time_data>, <type>)
            this.o_code = o_code;
            this.data = data;
            if nargin == 2
                this.type = LS_Parametrization.CONST;
            elseif nargin == 3
                this.type = LS_Parametrization.SPLINE_LIN;
            elseif nargin == 4
                this.type = type;
                this.time_data = time_data;
            end
        end
        function bias = getBias(this,time)
            % get the electronic bias
            %
            % SYTANX
            % bias = getBias(this,<time>)
            log  = Core.getLogger;

            if nargin == 1
                if this.type == this.CONST
                    bias = this.data;
                else
                    log.addError('Type not const but no time requested')
                end
            end
            if this.type == LS_Parametrization.CONST
                bias = this.data;
            elseif this.type == LS_Parametrization.SPLINE_LIN
                 spl_rate = this.time_data.getRate;
                 int_time = (time - this.time_data.first);
                 ep_id = floor(int_time/spl_rate);
                 spline_v = Core_Utils.spline(rem(int_time,spl_rate)/spl_rate,1);
                 bias = spline_v(:,1) .* this.data(ep_id +1) + spline_v(:,2) .* this.data(min(ep_id +2,length(this.data)));
            elseif this.type == LS_Parametrization.SPLINE_CUB
                 spl_rate = this.time_data.getRate;
                 int_time = (time - this.time_data.first);
                 ep_id = floor(int_time/spl_rate);
                 interp_ep = ep_id >= 0 & ep_id < length(this.data);
                 bias = zeros(this.time_data.length,1);
                 if any(interp_ep)
                     spline_v = Core_Utils.spline(rem(int_time(interp_ep),spl_rate)/spl_rate,3);
                     bias(interp_ep) = spline_v(:,1) .* this.data(ep_id(interp_ep) +1)' + spline_v(:,2) .* this.data(min(ep_id(interp_ep) +2,length(this.data)))' + spline_v(:,3) .* this.data(min(ep_id(interp_ep) +3,length(this.data)))' + spline_v(:,4) .* this.data(min(ep_id(interp_ep) +4,length(this.data)))';
                 end
                 if any(~interp_ep)
                     bf_ep = ep_id < 0;
                     bias(bf_ep) = bias(find(interp_ep,1,'first'));
                     aft_ep = ep_id >= length(this.data);
                     bias(aft_ep) =bias(find(interp_ep,1,'last'));
                     %log.addWarning('Epoch requested out of time boundaries, extrapolating');
                 end
            end
            
        end
    end
end