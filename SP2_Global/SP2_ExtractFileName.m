%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [fileName, f_succ] = SP2_ExtractFileName(filePath)
%% 
%%  Extract file name from absolute file path.
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag

FCTNAME = 'SP2_ExtractFileName';


%--- init success flag ---
f_succ   = 0;
fileName = '';

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
fileName = filePath(slashInd(end)+1:end);

%--- update success flag ---
f_succ = 1;




