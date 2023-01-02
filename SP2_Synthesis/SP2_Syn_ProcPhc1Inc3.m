%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_ProcPhc1Inc3
%% 
%%  10deg increase of first order phase correction
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm syn flag


%--- update value spec 1 ---
syn.procPhc1 = syn.procPhc1 + 10;
set(fm.syn.procPhc1Val,'String',sprintf('%.1f',syn.procPhc1))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
