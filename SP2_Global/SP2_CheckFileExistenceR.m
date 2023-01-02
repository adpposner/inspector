%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_YesNo = SP2_CheckFileExistenceR(filePath,varargin)
%%
%%  function f_exist = SP2_CheckFileExistenceR(filePath)
%%  Checks the existence of a particular file 'filePath'. If the 'filePath' is not existing
%%  function SP2_CheckDirAccessR.m is used to check the path accessibility.
%%  The only difference to SP2_CheckFileExistence.m is that here a variable is returned
%%  that shows the existence (f_YesNo=1) or not (f_YesNo=0) and without
%%  error message.
%% 
%%  03-2005, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_CheckFileExistenceR';

%--- check path format ---
if ~SP2_Check4Str(filePath)
    return
end

%--- verbose handling ---
f_verbose = 1;          % default: verbose
if nargin==2
    f_verbose = SP2_Check4FlagR(varargin{1});
end

if exist(filePath)~=2
    if flag.OS>0            % 1: linux, 2: mac
        slashInd = findstr(filePath,'/');                        % get slash positions
    else                    % 0: PC
        slashInd = findstr(filePath,'\');                        % get slash positions
    end
    if isempty(slashInd)
        if f_verbose
            fprintf('%s ->\nAbsolute path names are required as function argument\n',FCTNAME);
        end
    else
        dirPath = filePath(1:slashInd(length(slashInd)));        % extract directory path
        [f_YesNo,maxPath,f_done] = SP2_CheckDirAccessR(dirPath);
        if f_YesNo
            if f_verbose
                fprintf('%s ->\nFile <%s> doesn''t exist,\neven if directory\n<%s> is accessible\n',FCTNAME,filePath,maxPath);
            end
        else
            if f_verbose
                fprintf('%s ->\nFile <%s> doesn''t exist;\nmaximum accessible directory: <%s>\n',FCTNAME,filePath,maxPath);
            end
        end
    end
    f_YesNo = 0;
else
    f_YesNo = 1;
end
