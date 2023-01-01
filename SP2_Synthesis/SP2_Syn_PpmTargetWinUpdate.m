%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmTargetWinUpdate
%% 
%%  Update of target frequency window.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn


%--- update ppm window ---
syn.ppmTargetMin = str2num(get(fm.syn.ppmTargetMin,'String'));
syn.ppmTargetMax = str2num(get(fm.syn.ppmTargetMax,'String'));
set(fm.syn.ppmTargetMin,'String',sprintf('%.2f',syn.ppmTargetMin))
set(fm.syn.ppmTargetMax,'String',sprintf('%.2f',syn.ppmTargetMax))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
