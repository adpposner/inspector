%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Tools_AnonDirSelect
%% 
%%  Function for directory path selection
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm tools

FCTNAME = 'SP2_Tools_AnonDirSelect';


%--- check directory access ---
tools.anonDir = SP2_DirAccessMax(tools.anonDir);

%--- browse to select the study directory ---
toolsAnonDir = uigetdir(tools.anonDir,'Select study path');    % select data file
if ~toolsAnonDir            % buffer select cancelation
    fprintf('%s aborted.\n',FCTNAME);
    return
end
tools.anonDir = toolsAnonDir;
tools.anonDir = SP2_GuaranteeFinalSlash(tools.anonDir);

%--- check directory accessibility ---
if ~SP2_CheckDirAccess(tools.anonDir)
    return
end
set(fm.tools.anonDirPath,'String',tools.anonDir);









end
