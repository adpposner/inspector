%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_PpmBinsUpdate
%% 
%%  Update number of spectral bins for noise analysis.
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm stab


%--- update cut-off value ---
stab.ppmBins = str2double(get(fm.stab.ppmBins,'String'));
set(fm.stab.ppmBins,'String',sprintf('%.0f',stab.ppmBins))

%--- window update ---
SP2_Stab_StabilityWinUpdate

