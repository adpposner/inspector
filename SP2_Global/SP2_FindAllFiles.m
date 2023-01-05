%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [totFileCell, f_succ] = SP2_FindAllFiles(targetDir)
%%
%%  function [totFileCell, f_succ] = SP2_FindAllFiles(targetDir)
%%  Checks if variable 'pars' has been assigned an numeric value. If not an error message
%%  is return, if it is, nothing is returned. The function is used to check function
%%  arguments for correct parameter format. Doing so, the user gets to know, what the
%%  problem is instead of a noninformative error message, when programs crash at a later
%%  stage.
%%
%%  Christoph Juchem, 08-2005
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FCTNAME = 'SP2_FindAllFiles';


%--- init success flag ---
f_succ = 0;

%--- find all files ---
[totFileCell, dirCell] = SP_Loc_FileAndDirExtraction(targetDir);
for dCnt = 1:length(dirCell)
    fileCell = SP2_FindAllFiles(dirCell{dCnt});
    totFileCell = [totFileCell fileCell];
end

%--- update success flag ---
f_succ = 1;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    L O C A L    F U N C T I O N S                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- sorting of directory content in 1) files and 2) subdirectories ---
function [fileCell, dirCell] = SP_Loc_FileAndDirExtraction(parentDir)

allStruct = dir(parentDir);
dirCell   = {};          % directory cell
fileCell  = {};          % file cell
dCnt      = 0;           % directory counter
fCnt      = 0;           % file counter
for allCnt = 1:length(allStruct)
    if ~strcmp(allStruct(allCnt).name,'.') && ~strcmp(allStruct(allCnt).name,'..')
        if allStruct(allCnt).isdir          % directory
            dCnt = dCnt + 1;
            dirCell{dCnt} = [parentDir allStruct(allCnt).name '/'];
        else                                % file
            fCnt = fCnt + 1;
            fileCell{fCnt} = [parentDir allStruct(allCnt).name];
        end
    end
end

