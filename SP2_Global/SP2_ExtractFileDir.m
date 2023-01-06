%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [fileDir, f_succ] = SP2_ExtractFileDir(filePath)
%% 
%%  Extract file directory from absolute file path.
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_ExtractFileDir';


%--- init success flag ---
f_succ   = 0;
fileDir  = '';

%--- check consistency ---
if ~SP2_Check4Str(filePath)
    return
end

%--- fid file assignment ---
if ~any(filePath=='/') && ~any(filePath=='\')
    fprintf('\n%s ->\nAssigned absolute file path is not valid. Program aborted.\n',FCTNAME);
    fprintf('<%s>\n',filePath);
    return
end

%--- path handling ---
if flag.OS==1            % Linux
    slashInd = find(filePath=='/');
elseif flag.OS==2        % Mac
    slashInd = find(filePath=='/');
else                     % PC
    slashInd = find(filePath=='\');
end
fileDir  = filePath(1:slashInd(end));

%--- update success flag ---
f_succ = 1;





end
