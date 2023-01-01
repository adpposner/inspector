%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_OffsetValueFlagUpdate
%% 
%%  Updates radiobutton setting: baseline offset mode
%%  1: mean of ppm range
%%  0: direct assignment of offset value
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- retrieve parameter ---
flag.synOffset = ~get(fm.syn.offsetValFlag,'Value');

%--- switch radiobutton ---
set(fm.syn.offsetPpmFlag,'Value',flag.synOffset)
set(fm.syn.offsetValFlag,'Value',~flag.synOffset)

%--- update window ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
