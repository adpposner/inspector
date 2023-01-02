%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_FormatMagnUpdate
%% 
%%  Visualization mode:
%%  1) real
%%  2) magnitude
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- direct assignment ---
flag.t1t2Format = ~get(fm.t1t2.formatMagn,'Value');

%--- switch radiobutton ---
set(fm.t1t2.formatReal,'Value',flag.t1t2Format)
set(fm.t1t2.formatMagn,'Value',~flag.t1t2Format)

%--- update window ---
SP2_T1T2_T1T2WinUpdate


