%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_AnaSignPositiveUpdate
%% 
%%  Perform SNR/FWHM/integration analysis for peak of positive polarity.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.synAnaSign = get(fm.syn.anaSignPos,'Value');

%--- window update ---
set(fm.syn.anaSignPos,'Value',flag.synAnaSign)
set(fm.syn.anaSignNeg,'Value',~flag.synAnaSign)

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
