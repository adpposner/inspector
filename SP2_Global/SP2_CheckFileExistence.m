%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    function f_succ = SP2_CheckFileExistence(filePath)
%%
%%  function SP2_CheckFileExistence(filePath)
%%  Checks the existence of a particular file 'filePath'. If the 'filePath' is not existing
%%  function SP2_CheckDirAccess.m is used to check the path accessibility.
%% 
%%  06-2004, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag

FCTNAME = 'SP2_CheckFileExistence';

%--- init success flag ---
f_succ = 0;

%--- parameter check ---
if ~SP2_Check4Str(filePath)
    return
end

%--- check path existence ---
if exist(filePath)~=2
    fprintf('%s ->\nFile <%s> couldn''t be found...\n',FCTNAME,filePath);
    if flag.OS>0                 % 1: linux, 2: mac
        slashInd = findstr(filePath,'/');                        % get slash positions
    else                         % 0: PC
        slashInd = findstr(filePath,'\');                        % get slash positions
    end
    if isempty(slashInd)
        fprintf('%s ->\nAbsolute path names are required as function argument\n',FCTNAME);
        return
    end
    dirPath = filePath(1:slashInd(length(slashInd)));        % extract directory path
    if ~SP2_CheckDirAccess(dirPath)                                  % if dirPath is not accessible, an error message is returned
        return
    end
    fprintf('%s ->\nFile <%s> doesn''t exist,\nbut directory\n<%s> is accessible\n'...
            ,FCTNAME,filePath,dirPath)
end

%--- update success flag ---
f_succ = 1;


