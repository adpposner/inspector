%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_SpecSelectUpdate
%% 
%%  Spectral analysis of a selected spectrum.
%%
%%  01-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm stab


%--- update cut-off value ---
stab.specSel = str2double(get(fm.stab.specSel,'String'));

%--- consistency check ---
stab.specSel = max(round(stab.specSel),1);

%--- update display ---
set(fm.stab.specSel,'String',sprintf('%.0f',stab.specSel))

%--- window update ---
SP2_Stab_StabilityWinUpdate