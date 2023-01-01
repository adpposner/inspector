%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_OffsetPpmWinUpdate
%% 
%%  Update offset entries.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn


%--- update amplitude window ---
syn.ppmOffsetMin = str2double(get(fm.syn.ppmOffsetMin,'String'));
syn.ppmOffsetMax = str2double(get(fm.syn.ppmOffsetMax,'String'));
set(fm.syn.ppmOffsetMin,'String',sprintf('%.2f',syn.ppmOffsetMin))
set(fm.syn.ppmOffsetMax,'String',sprintf('%.2f',syn.ppmOffsetMax))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
