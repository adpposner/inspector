%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AnaFormatMagnUpdate
%% 
%%  Visualization mode:
%%  1) real
%%  0) magnitude
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- direct assignment ---
flag.mmAnaFormat = 0;

%--- switch radiobutton ---
set(fm.mm.anaFormatReal,'Value',flag.mmAnaFormat)
set(fm.mm.anaFormatMagn,'Value',~flag.mmAnaFormat)

%--- update window ---
SP2_MM_MacroWinUpdate



end
