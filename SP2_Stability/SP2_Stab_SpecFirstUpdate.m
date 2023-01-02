%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_SpecFirstUpdate
%% 
%%  Update of 1st spectrum number (to be analyzed).
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm stab


%--- update value ---
stab.specFirst = str2double(get(fm.stab.specFirst,'String'));

%--- consistency check ---
stab.specFirst = min(max(round(stab.specFirst),1),stab.specLast);

%--- update window ---
set(fm.stab.specFirst,'String',sprintf('%.0f',stab.specFirst))

%--- window update ---
SP2_Stab_StabilityWinUpdate

