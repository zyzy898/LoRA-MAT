% killProcesses kills processes that match given keywords and, optionally, have exceeded a CPU time limit.
%
% INPUT
%   keywords      - cell array of strings representing keywords to filter the processes by
%   max_time      - (optional) maximum CPU time in seconds; processes exceeding this will be killed
%
% OUTPUT
%   None
%
% This function uses the getProcesses function to retrieve a list of processes
% matching the specified keywords. If max_time is provided, only processes with a CPU time
% greater than max_time will be targeted for termination.
%
% SYNTAX
%   killProcesses(keywords)
%   killProcesses(keywords, max_time)
%
% EXAMPLE USAGE
%   killProcesses({'notepad', 'matlab'})
%   This will kill all processes that have 'notepad' or 'matlab' in their command line or path.
%
%   killProcesses({'python'}, 3600)
%   This will kill all 'python' processes running longer than 3600 seconds (1 hour).
%

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:        Andrea Gatti
%  Contributors:      Andrea Gatti
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

function killProcesses(keywords, max_time)

    % Check if the max_time argument is provided
    if nargin < 2
        max_time = 0; % If not provided, set it to 0
    end

    % Retrieve the list of running processes matching the keywords
    processes = getProcesses(keywords);

    % Loop through the processes and kill those that match the criteria
    for i = 1:length(processes)
        process = processes(i);
        if ~isempty(process) && process.cpu_time > max_time
            % Kill the process
            if ispc
                killCommand = sprintf('taskkill /PID %d /F', process.pid);
            elseif isunix
                killCommand = sprintf('kill -9 %d', process.pid);
            else
                error('Unsupported operating system.');
            end

            % Execute the kill command
            [status, cmdout] = system(killCommand);
            if status == 0
                fprintf('Process with PID %d killed successfully.\n', process.pid);
            else
                fprintf('Failed to kill process with PID %d: %s\n', process.pid, cmdout);
            end
        end
    end
end