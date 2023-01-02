%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_SpecLastUpdate
%% 
%%  Update of last spectrum number (to be analyzed).
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm stab


%--- update value ---
stab.specLast = str2double(get(fm.stab.specLast,'String'));

%--- consistency check ---
stab.specLast = max(round(stab.specLast),stab.specFirst);

%--- update window ---
set(fm.stab.specLast,'String',sprintf('%.0f',stab.specLast))

%--- window update ---
SP2_Stab_StabilityWinUpdate

