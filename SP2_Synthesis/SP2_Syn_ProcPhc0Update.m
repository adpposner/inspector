%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_ProcPhc0Update
%% 
%%  Update of zero order phase correction value for spectrum 1
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm syn flag


%--- update value spec 1 ---
syn.procPhc0 = str2num(get(fm.syn.procPhc0Val,'String'));
set(fm.syn.procPhc0Val,'String',sprintf('%.1f',syn.procPhc0))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
