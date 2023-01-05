%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_AnaFwhmUpdate
%% 
%%  Switching on/off FWHM analysis.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.synAnaFWHM = get(fm.syn.anaFWHM,'Value');

%--- window update ---
set(fm.syn.anaFWHM,'Value',flag.synAnaFWHM)

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
