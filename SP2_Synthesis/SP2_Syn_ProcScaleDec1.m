%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_ProcScaleDec1
%% 
%%  0.001 reduced scaling of spectrum 1.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn flag


%--- update value spec 1 ---
syn.procScale = syn.procScale - 0.1;
set(fm.syn.procScaleVal,'String',sprintf('%.3f',syn.procScale))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

end
