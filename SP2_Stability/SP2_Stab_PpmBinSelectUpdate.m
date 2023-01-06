%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_PpmBinSelectUpdate
%% 
%%  Update number of selected bins for noise analysis.
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm stab


%--- update cut-off value ---
stab.ppmBinSel = str2double(get(fm.stab.ppmBinSel,'String'));

%--- consistency check ---
stab.ppmBinSel = max(round(stab.ppmBinSel),1);

%--- update display ---
set(fm.stab.ppmBinSel,'String',sprintf('%.0f',stab.ppmBinSel))

%--- window update ---
SP2_Stab_StabilityWinUpdate


end
