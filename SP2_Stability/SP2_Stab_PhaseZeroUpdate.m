%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_PhaseZeroUpdate
%% 
%%  Update zero-order phase.
%%
%%  06-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm stab


%--- update cut-off value ---
stab.phc0 = str2double(get(fm.stab.phc0,'String'));
set(fm.stab.phc0,'String',sprintf('%.0f',stab.phc0))

%--- window update ---
SP2_Stab_StabilityWinUpdate

