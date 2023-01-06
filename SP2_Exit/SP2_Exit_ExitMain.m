%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Exit_ExitMain
%% 
%%  Exit function (after saving the parameter settings to file for next 
%%  function call.
%%
%%  11-2018, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Exit_ExitMain';


%--- open yes/no dialog ---
choice = questdlg('Do you really want to quit INSPECTOR?','Exit Dialog', ...
              'Yes','No','Yes');

%--- combination of GlucoseA/B ---
if strcmp(choice,'No')
    return
end

%--- delete local windows ---
SP2_Exit_ExitFct
end
