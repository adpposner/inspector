%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_ProcZfReset
%% 
%%  Reset ZF for spectrum 1.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn flag


%--- update percentage value ---
syn.procZf = 16384;
set(fm.syn.procZfVal,'String',sprintf('%.0f',syn.procZf))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

end
