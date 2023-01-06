%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_FormatMagnUpdate
%% 
%%  Updates radiobutton setting: spectrum visualization
%%  1) real
%%  2) imaginary
%%  3) magnitude
%%  4) phase
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- direct assignment ---
flag.synFormat = 3;

%--- switch radiobutton ---
set(fm.syn.formatReal,'Value',flag.synFormat==1)
set(fm.syn.formatImag,'Value',flag.synFormat==2)
set(fm.syn.formatMagn,'Value',flag.synFormat==3)
set(fm.syn.formatPhase,'Value',flag.synFormat==4)

%--- update window ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

end
