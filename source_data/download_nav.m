function [download_successful, compressed] = download_nav(filename, nav_path)

% SYNTAX:
%   [download_successful, compressed] = download_nav(filename, nav_path);
%
% INPUT:
%   filename = name of the RINEX navigation file to be downloaded
%   (brdcddd0.yyn, brdmddd0.yyp and CGIMddd0.yyN supported)
%   nav_path = download path
%
% OUTPUT:
%   download_successful = flag to identify unsuccessful downloads
%   compressed = flag to let the calling function know whether the
%                downloaded files are still compressed
%
% DESCRIPTION:
%   Download of RINEX navigation files from the IGS or AIUB FTP servers.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:
%  Contributors:     ...
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

% Pointer to the global settings:
state = Core.getCurrentSettings();

download_successful = 0;
compressed = 0;

%IGS FTP server URL
igs_url = 'geodesy.noaa.gov';
igs_mirror = 'igs-ftp.bkg.bund.de';

%AIUB FTP server URL
aiub_url = 'ftp.aiub.unibe.ch';

%download directory
if (nargin < 2)
    down_dir = state.eph_dir;
else
    down_dir = nav_path;
end

% Check / create output folder
if not(exist(down_dir, 'dir'))
    mkdir(down_dir);
end

[~, file_name, file_ext] = fileparts(filename); 
filename = [file_name file_ext];

%identify requested file type
if (strcmp(filename(1:4),'brdc'))
    %url = igs_url;
    %name = 'IGS';
    %path = '/pub/gps/data/daily/';
    %subdir = '/brdc/';
    url = igs_mirror;
    name = 'BKG IGS mirror';
    path = '/IGS/BRDC/';
    subdir = sprintf('/%s/', filename(5:7));
elseif (strcmp(filename(1:4),'CGIM'))
    url = aiub_url;
    name = 'AIUB';
    path = '/aiub/CODE/';
    subdir = '';
else
    error('Only "brdc", "CGIM" (AIUB) files are supported.');
end

fprintf(['FTP connection to the ' name ' server (ftp://' url '). Please wait...'])

%connect to the server
try
    ftp_server = ftp(url, 'anonymous', 'info@g-red.eu');
    warning('off')
    sf = struct(ftp_server);
    warning('on')
    %% sf.jobject.enterLocalPassiveMode();
catch
    fprintf(['Could not connect to: ' url ' \n']);
    return
end

fprintf('\n');

%target directory
s = [path num2str(four_digit_year(str2num(filename(end-2:end-1)))) subdir];

cd(ftp_server, '/');
try
    cd(ftp_server, s); % If the folder does not exist go to the catch branch of try
    
    filename = [filename '.gz'];
    
    try
        mget(ftp_server,filename,down_dir);
        Core_Utils.uncompressFile(char(fullfile(down_dir,filename)))
        fprintf(['Downloaded ' filename(1:4) ' file: ' filename '\n']);
        download_successful = 1;
    catch
    end    
catch
    warning('"%s" folder not found in %s', s, ftp_server.Host);
end

close(ftp_server);

fprintf('Download complete.\n')