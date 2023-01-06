%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_AmplWinUpdate
%% 
%%  Update amplitude window
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn


%--- update amplitude window ---
syn.amplMin = str2num(get(fm.syn.amplMin,'String'));
syn.amplMax = str2num(get(fm.syn.amplMax,'String'));
set(fm.syn.amplMin,'String',sprintf('%.0f',syn.amplMin))
set(fm.syn.amplMax,'String',sprintf('%.0f',syn.amplMax))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate


end
