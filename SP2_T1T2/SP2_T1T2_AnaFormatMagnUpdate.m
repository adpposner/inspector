%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_T1T2_AnaFormatMagnUpdate
%% 
%%  Visualization mode:
%%  1) real
%%  2) magnitude
%%
%%  08-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- direct assignment ---
flag.t1t2AnaFormat = ~get(fm.t1t2.anaFormatMagn,'Value');

%--- switch radiobutton ---
set(fm.t1t2.anaFormatReal,'Value',flag.t1t2AnaFormat)
set(fm.t1t2.anaFormatMagn,'Value',~flag.t1t2AnaFormat)

%--- update window ---
SP2_T1T2_T1T2WinUpdate


