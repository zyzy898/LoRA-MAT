function undersamplingRINEX(filenameIN, filenameOUT, base, step, delta, wait_dlg)

% SYNTAX:
%   undersamplingRINEX(filenameIN, filenameOUT, base, step, delta, wait_dlg);
%
% INPUT:
%   filenameIN  = input RINEX observation file
%   filenameOUT = output RINEX observation file
%   base  = base timing (e.g. if first epoch should be 13  4  5 11 35  1, then base = 1) [sec]
%   step  = new sampling rate [sec]
%   delta = original sampling rate [sec]
%   wait_dlg = optional handler to waitbar figure (optional)
%
% OUTPUT:
%
%
% DESCRIPTION:
%   Undersamples a RINEX observation file.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

%default values
if (nargin < 3)
    base  = 0;
end

if (nargin < 4)
    step  = 30;
end

if (nargin < 5)
    delta = 1;
end

% ------------------------------------------
% header copy and paste
% ------------------------------------------

fidIN  = fopen(filenameIN,'rt');
fidOUT = fopen(filenameOUT,'wt');

line = fgets(fidIN);
while (isempty(strfind(line,'END OF HEADER')))
   fprintf(fidOUT,'%s',line);
   line = fgets(fidIN);
   if (~isempty(strfind(line,'INTERVAL')))
       line = sprintf('%10.3f                                                  INTERVAL            \n', step);
   end
end
fprintf(fidOUT,line);

% fclose(fidIN);
% fclose(fidOUT);

% ------------------------------------------
% undersampling
% ------------------------------------------

while (feof(fidIN) == 0)

    % time (seconds) extraction
	sec = roundmod(str2num(line(17:27)),delta);
	%fprintf('%d\n',sec);           % debugging

	if (mod(sec-base,step) == 0)    % if it is a header message
		fprintf(fidOUT,'%s',line);
		line = fgets(fidIN);
		%fprintf('%s',line);        % debugging
		while (feof(fidIN) == 0) & ...
		      ((line(1) ~= ' ') | (line(2) == ' ') | ...
		       (line(3) == ' ') | (line(4) ~= ' '))
			fprintf(fidOUT,'%s',line);
			line = fgets(fidIN);
			%fprintf('%s',line);    % debugging
        end
        if (feof(fidIN) == 1) && ~isempty(line)
            fprintf(fidOUT,'%s',line);
        end
	else                            % if it is a data message
		line = fgets(fidIN);
		%fprintf('%s',line);        % debugging
		while (feof(fidIN) == 0) & ...
		      ((line(1) ~= ' ') | (line(2) == ' ') | ...
		       (line(3) == ' ') | (line(4) ~= ' '))
			line = fgets(fidIN);
			%fprintf('%s',line);    % debugging
		end
	end
end

fclose(fidIN);      % input file closure
fclose(fidOUT);     % output file closure