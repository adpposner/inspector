%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_CreateFctList4StandAlone(varargin)
%% 
%%  Creates a function (M-file) SPx_FctList4StandAlone within the same
%%  directory that contains nothing else but a list of all M-file of the
%%  parent INSPECTOR directory. This is necessary for creating stand-alone
%%  applications.
%%
%%  12-2007, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

vNum = 2;                       % default: INSPECTOR software version


explicitCell = {'atamult'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---    P R O G R A M     S T A R T                                     ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FCTNAME = 'SP2_CreateFctList4StandAlone';

%--- argument handling: software version ---
if nargin==1
    vNum = SP2_Check4IntBigger0( varargin{1} );
end
vStr = num2str(vNum);

%--- path creation ---
fmStruct = what(['INSPECTOR_v' vStr]);
if isempty(fmStruct) || ~isfield(fmStruct,'path')
    fprintf('%s ->\nCouldn''t find the main program file\n',FCTNAME);
    fprintf('Check folder name/existence <INSPECTOR_v%i> and software version...\n',vNum);
    return
end
if ispc
    flag.OS = 0;
elseif ismac
    flag.OS = 2;
else
    flag.OS = 1;
end
fmPath = fmStruct.path;      % substitute / by \
fmFile = [fmPath '\SP' vStr '_global\SP' vStr '_FctList4StandAlone.m'];
fmFile = fmFile;

%--- script file generation ---
[unit,msg] = fopen(fmFile,'w');
if ~isempty(msg)
    fprintf('%s ->\nCould not create/open\n<%s>\n',FCTNAME,fmFile);
    fprintf(msg);
    return
end
fprintf(unit, 'function SP2_FctList4StandAlone\n');

%--- retrieve FMx file names (and paths) ---
keyStr = ['SP' vStr '_'];
pNames = SP2_GetAllFiles(fmPath);                       % retrieve all files from current and subdirectories (path names)
flen   = length(pNames);                    % number of files
fcnt   = 0;                                 % file counter for the files to be modified
fprintf('%s -> retrieving files ...\n',FCTNAME);
for icnt = 1:flen
    if flag.OS==1               % Linux
        lastSlash(icnt) = max(find('/'==char(pNames(icnt))));       % last slash
    elseif flag.OS==2           % Mac
        lastSlash(icnt) = max(find('/'==char(pNames(icnt))));       % last slash
    else                        % PC
        lastSlash(icnt) = max(find('\'==char(pNames(icnt))));       % last slash
    end
    if strcmp(pNames{icnt}(end-1:end),'.m')                         % only .m files
        fNames{icnt} = pNames{icnt}(lastSlash(icnt)+1:end);         % cell array of pure file names
        if ~isempty(findstr(char(fNames{icnt}),keyStr)) && isempty(findstr(char(fNames{icnt}),'.exe'))
            fullPath = char(fNames{icnt});                          % full path and file name including '.m'
            fprintf(unit, '%%#function %s\n', fullPath(1:end-2));   % file name only (without extension);
            fprintf('<%s> added to list\n',pNames{icnt});
        end
    end
end
for icnt = 1:length(explicitCell)
    fprintf(unit, '%%#function %s\n',explicitCell{icnt});       % file name only (without extension);
    fprintf('<%s> added to list\n',explicitCell{icnt});
end
fclose(unit);
fprintf('file <%s> successfully created\n\n',fmFile);
