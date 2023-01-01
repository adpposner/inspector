%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [f_YesNo, f_succ] = SP2_CheckDirWritePermR(dirPath,varargin)
%%
%%  function [f_YesNo, f_succ] = SP2_CheckDirWritePermR(dirPath)
%%
%%  Checks for write access.
%%
%%  11-2018, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_CheckDirWriterPermR';


%--- init success flag ---
f_YesNo = 0;
f_succ  = 0;

%--- check path format ---
if ~SP2_Check4Str(dirPath)
    return
end

%--- get permissions ---
[f_done,msg,msgId] = fileattrib(dirPath);
if ~f_done
    fprintf('\n\n%s ->\nRetrieval of directory permissions failed for\n',FCTNAME)
    fprintf('%s\n',dirPath)
    fprintf('Program aborted.\n\n')
    return
end
f_YesNo = msg.UserWrite;

%--- update success flag ---
f_succ = 1;






